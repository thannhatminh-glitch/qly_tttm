const path = require("path");
const express = require("express");
const mysql = require("mysql2");
const cors = require("cors");

const PORT = 3000;
const IDENTIFIER_PATTERN = /^[A-Za-z_][A-Za-z0-9_]*$/;

const app = express();
app.use(cors());
app.use(express.json());
app.use(express.static(__dirname));

const db = mysql.createPool({
    host: "localhost",
    user: "root",
    password: "123456",
    database: "TTTM",
    waitForConnections: true,
    connectionLimit: 10
}).promise();

function asyncHandler(handler) {
    return (req, res, next) => {
        Promise.resolve(handler(req, res, next)).catch(next);
    };
}

function assertIdentifier(name, label) {
    if (!IDENTIFIER_PATTERN.test(name)) {
        const error = new Error(`${label} không hợp lệ.`);
        error.status = 400;
        throw error;
    }

    return name;
}

function escapeIdentifier(name, label) {
    return mysql.escapeId(assertIdentifier(name, label));
}

function formatColumn(column) {
    return {
        name: column.Field,
        type: column.Type,
        nullable: column.Null === "YES",
        key: column.Key,
        defaultValue: column.Default,
        extra: column.Extra
    };
}

function pickPayload(body, columns, excludedFields = []) {
    const allowedFields = new Set(columns.map((column) => column.Field));
    const excluded = new Set(excludedFields);
    const payload = {};

    Object.entries(body || {}).forEach(([key, value]) => {
        if (allowedFields.has(key) && !excluded.has(key)) {
            payload[key] = value;
        }
    });

    return payload;
}

async function getColumns(table) {
    const safeTable = escapeIdentifier(table, "Tên bảng");
    const [columns] = await db.query(`SHOW COLUMNS FROM ${safeTable}`);
    return columns;
}

async function ensureColumns(table) {
    const columns = await getColumns(table);

    if (!columns.length) {
        const error = new Error(`Không tìm thấy cấu trúc của bảng ${table}.`);
        error.status = 404;
        throw error;
    }

    return columns;
}

function ensureFieldExists(field, columns) {
    assertIdentifier(field, "Tên cột");

    const exists = columns.some((column) => column.Field === field);
    if (!exists) {
        const error = new Error(`Không tìm thấy cột ${field}.`);
        error.status = 400;
        throw error;
    }
}

app.get("/", (req, res) => {
    res.sendFile(path.join(__dirname, "index.html"));
});

app.get("/api/tables", asyncHandler(async (req, res) => {
    const [rows] = await db.query("SHOW TABLES");
    const tables = rows.map((row) => Object.values(row)[0]);
    res.json({ tables });
}));

app.get("/api/:table/meta", asyncHandler(async (req, res) => {
    const table = req.params.table;
    const columns = await ensureColumns(table);

    res.json({
        table,
        columns: columns.map(formatColumn)
    });
}));

app.get("/api/:table", asyncHandler(async (req, res) => {
    const table = req.params.table;
    await ensureColumns(table);

    const safeTable = escapeIdentifier(table, "Tên bảng");
    const [rows] = await db.query(`SELECT * FROM ${safeTable}`);
    res.json(rows);
}));

app.get("/api/:table/:field/:id", asyncHandler(async (req, res) => {
    const { table, field, id } = req.params;
    const columns = await ensureColumns(table);
    ensureFieldExists(field, columns);

    const safeTable = escapeIdentifier(table, "Tên bảng");
    const safeField = escapeIdentifier(field, "Tên cột");
    const [rows] = await db.query(
        `SELECT * FROM ${safeTable} WHERE ${safeField} = ? LIMIT 1`,
        [id]
    );

    if (!rows.length) {
        return res.status(404).json({ message: "Không tìm thấy bản ghi." });
    }

    res.json(rows[0]);
}));

app.post("/api/:table", asyncHandler(async (req, res) => {
    const table = req.params.table;
    const columns = await ensureColumns(table);
    const payload = pickPayload(req.body, columns);

    if (!Object.keys(payload).length) {
        return res.status(400).json({ message: "Không có dữ liệu hợp lệ để thêm." });
    }

    const safeTable = escapeIdentifier(table, "Tên bảng");
    const [result] = await db.query(`INSERT INTO ${safeTable} SET ?`, payload);

    res.status(201).json({
        message: "Thêm dữ liệu thành công.",
        insertId: result.insertId
    });
}));

app.put("/api/:table/:field/:id", asyncHandler(async (req, res) => {
    const { table, field, id } = req.params;
    const columns = await ensureColumns(table);
    ensureFieldExists(field, columns);

    const payload = pickPayload(req.body, columns, [field]);
    if (!Object.keys(payload).length) {
        return res.status(400).json({ message: "Không có dữ liệu hợp lệ để cập nhật." });
    }

    const safeTable = escapeIdentifier(table, "Tên bảng");
    const safeField = escapeIdentifier(field, "Tên cột");
    const [result] = await db.query(
        `UPDATE ${safeTable} SET ? WHERE ${safeField} = ?`,
        [payload, id]
    );

    if (result.affectedRows === 0) {
        return res.status(404).json({ message: "Không tìm thấy bản ghi để cập nhật." });
    }

    res.json({ message: "Cập nhật dữ liệu thành công." });
}));

app.delete("/api/:table/:field/:id", asyncHandler(async (req, res) => {
    const { table, field, id } = req.params;
    const columns = await ensureColumns(table);
    ensureFieldExists(field, columns);

    const safeTable = escapeIdentifier(table, "Tên bảng");
    const safeField = escapeIdentifier(field, "Tên cột");
    const [result] = await db.query(
        `DELETE FROM ${safeTable} WHERE ${safeField} = ?`,
        [id]
    );

    if (result.affectedRows === 0) {
        return res.status(404).json({ message: "Không tìm thấy bản ghi để xóa." });
    }

    res.json({ message: "Xóa dữ liệu thành công." });
}));

app.use((err, req, res, next) => {
    if (err.code === "ER_NO_SUCH_TABLE") {
        return res.status(404).json({ message: "Bảng không tồn tại." });
    }

    console.error(err);
    res.status(err.status || 500).json({
        message: err.message || "Lỗi máy chủ."
    });
});

async function startServer() {
    try {
        await db.query("SELECT 1");
        console.log("MySQL connected");
        app.listen(PORT, () => {
            console.log(`Server chạy tại http://localhost:${PORT}`);
        });
    } catch (error) {
        console.error("Không thể kết nối MySQL:", error.message);
        process.exit(1);
    }
}

startServer();
