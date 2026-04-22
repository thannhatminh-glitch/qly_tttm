
CREATE DATABASE TTTM CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE TTTM;

-- ============================================================
-- PHẦN 1: TẠO CÁC BẢNG (17 BẢNG)
-- ============================================================

-- -------------------------------------------------------------
-- Bảng 1: KV_Cua_Hang (Khu vực - Loại cửa hàng)
-- Lược đồ: Kv_CuaHang(KhuVuc, LoaiCuaHang)
-- K = {khu_vuc}
-- -------------------------------------------------------------
CREATE TABLE KV_Cua_Hang (
    khu_vuc         VARCHAR(50)  NOT NULL,
    loai_cua_hang   VARCHAR(100) NOT NULL,
    PRIMARY KEY (khu_vuc)
);

-- -------------------------------------------------------------
-- Bảng 2: Quan_Li_Cua_Hang (Quản lí cửa hàng)
-- Lược đồ: QuanLiCuaHang(IdQuanLi, ThuongChucVu, ThamNienQuanLi)
-- K = {id_quan_li}
-- -------------------------------------------------------------
CREATE TABLE Quan_Li_Cua_Hang (
    id_quan_li          VARCHAR(10)    NOT NULL,
    thuong_chuc_vu      DECIMAL(15,2)  NOT NULL DEFAULT 0,
    tham_nien_quan_li   INT            NOT NULL DEFAULT 0,
    PRIMARY KEY (id_quan_li)
);

-- -------------------------------------------------------------
-- Bảng 3: Cua_Hang (Cửa hàng)
-- Lược đồ: CuaHang(IdCuaHang, KhuVuc, TenShop, IdQuanLi)
-- K = {id_cua_hang}
-- -------------------------------------------------------------
CREATE TABLE Cua_Hang (
    id_cua_hang VARCHAR(10)  NOT NULL,
    khu_vuc     VARCHAR(50)  NOT NULL,
    ten_shop    VARCHAR(100) NOT NULL,
    id_quan_li  VARCHAR(10)  NOT NULL,
    PRIMARY KEY (id_cua_hang),
    FOREIGN KEY (khu_vuc)   REFERENCES KV_Cua_Hang(khu_vuc),
    FOREIGN KEY (id_quan_li) REFERENCES Quan_Li_Cua_Hang(id_quan_li)
);

-- -------------------------------------------------------------
-- Bảng 4: Nhan_Vien (Nhân viên)
-- Lược đồ: NhanVien(IdNhanVien, TenNhanVien, Luong, SoNgayLam, IdGiamSat, IdCuaHang)
-- K = {id_nhan_vien}
-- -------------------------------------------------------------
CREATE TABLE Nhan_Vien (
    id_nhan_vien    VARCHAR(10)    NOT NULL,
    ten_nhan_vien   VARCHAR(100)   NOT NULL,
    luong           DECIMAL(15,2)  NOT NULL DEFAULT 0,
    so_ngay_lam     INT            NOT NULL DEFAULT 0,
    id_giam_sat     VARCHAR(10)    NULL,     -- Tự tham chiếu (NULL nếu là trưởng nhóm)
    id_cua_hang     VARCHAR(10)    NOT NULL,
    PRIMARY KEY (id_nhan_vien),
    FOREIGN KEY (id_giam_sat)  REFERENCES Nhan_Vien(id_nhan_vien),
    FOREIGN KEY (id_cua_hang)  REFERENCES Cua_Hang(id_cua_hang)
);

-- -------------------------------------------------------------
-- Bảng 5: NhanVien_SDT (Số điện thoại nhân viên - đa trị)
-- Lược đồ: NhanVienSDT(IdNhanVien, SDT)
-- K = {id_nhan_vien, sdt}
-- -------------------------------------------------------------
CREATE TABLE NhanVien_SDT (
    id_nhan_vien    VARCHAR(10) NOT NULL,
    sdt             VARCHAR(15) NOT NULL,
    PRIMARY KEY (id_nhan_vien, sdt),
    FOREIGN KEY (id_nhan_vien) REFERENCES Nhan_Vien(id_nhan_vien)
);

-- -------------------------------------------------------------
-- Bảng 6: Nha_Cung_Cap (Nhà cung cấp)
-- Lược đồ: NhaCungCap(IdNhaCungCap, SdtDaiDien, DiaChi, TenNhaCungCap, MucDoNoiTieng)
-- K = {id_nha_cung_cap}
-- -------------------------------------------------------------
CREATE TABLE Nha_Cung_Cap (
    id_nha_cung_cap     VARCHAR(10)  NOT NULL,
    sdt_dai_dien        VARCHAR(15)  NOT NULL,
    dia_chi             VARCHAR(200) NOT NULL,
    ten_nha_cung_cap    VARCHAR(100) NOT NULL,
    muc_do_noi_tieng    ENUM('Thấp','Trung bình','Cao','Rất cao') NOT NULL DEFAULT 'Trung bình',
    PRIMARY KEY (id_nha_cung_cap)
);

-- -------------------------------------------------------------
-- Bảng 7: Hang_Hoa (Hàng hóa)
-- Lược đồ: HangHoa(IdHangHoa, TenHangHoa, LoaiHangHoa)
-- K = {id_hang_hoa}
-- -------------------------------------------------------------
CREATE TABLE Hang_Hoa (
    id_hang_hoa     VARCHAR(10)  NOT NULL,
    ten_hang_hoa    VARCHAR(100) NOT NULL,
    loai_hang_hoa   VARCHAR(50)  NOT NULL,
    PRIMARY KEY (id_hang_hoa)
);

-- -------------------------------------------------------------
-- Bảng 8: Cung_Cap (Quan hệ Hàng hóa - Nhà cung cấp)
-- Lược đồ: CungCap(IdHangHoa, IdNhaCungCap, NgaySanXuat)
-- K = {id_hang_hoa, id_nha_cung_cap}
-- -------------------------------------------------------------
CREATE TABLE Cung_Cap (
    id_hang_hoa         VARCHAR(10) NOT NULL,
    id_nha_cung_cap     VARCHAR(10) NOT NULL,
    ngay_san_xuat       DATE        NOT NULL,
    PRIMARY KEY (id_hang_hoa, id_nha_cung_cap),
    FOREIGN KEY (id_hang_hoa)       REFERENCES Hang_Hoa(id_hang_hoa),
    FOREIGN KEY (id_nha_cung_cap)   REFERENCES Nha_Cung_Cap(id_nha_cung_cap)
);

-- -------------------------------------------------------------
-- Bảng 9: Giao_Dich (Lô hàng / Giao dịch nhập)
-- Lược đồ: GiaoDich(MaLo, IdHangHoa, IdNhaCungCap, ShopId, GiaCungCap, NgayCungCap, SoLuong)
-- K = {ma_lo}
-- -------------------------------------------------------------
CREATE TABLE Giao_Dich (
    ma_lo               VARCHAR(10)    NOT NULL,
    id_hang_hoa         VARCHAR(10)    NOT NULL,
    id_nha_cung_cap     VARCHAR(10)    NOT NULL,
    shop_id             VARCHAR(10)    NOT NULL,
    gia_cung_cap        DECIMAL(15,2)  NOT NULL,
    ngay_cung_cap       DATE           NOT NULL,
    so_luong            INT            NOT NULL CHECK (so_luong > 0),
    PRIMARY KEY (ma_lo),
    FOREIGN KEY (id_hang_hoa)       REFERENCES Hang_Hoa(id_hang_hoa),
    FOREIGN KEY (id_nha_cung_cap)   REFERENCES Nha_Cung_Cap(id_nha_cung_cap),
    FOREIGN KEY (shop_id)           REFERENCES Cua_Hang(id_cua_hang)
);

-- -------------------------------------------------------------
-- Bảng 10: Hoa_Don (Hóa đơn bán)
-- Lược đồ: HoaDon(IdHoaDon, NgayLap, TongGiaTri)
-- K = {id_hoa_don}
-- -------------------------------------------------------------
CREATE TABLE Hoa_Don (
    id_hoa_don      VARCHAR(10)    NOT NULL,
    ngay_lap        DATE           NOT NULL,
    tong_gia_tri    DECIMAL(15,2)  NOT NULL DEFAULT 0,
    PRIMARY KEY (id_hoa_don)
);

-- -------------------------------------------------------------
-- Bảng 11: Chi_Tiet_Hoa_Don (Chi tiết hóa đơn / Bảo hành)
-- Lược đồ: ChiTietHoaDon(IdChiTietHoaDon, IdHoaDon, NgayBatDauBaoHanh, NgayKetThucBaoHanh)
-- K = {id_chi_tiet_hoa_don, id_hoa_don}
-- -------------------------------------------------------------
CREATE TABLE Chi_Tiet_Hoa_Don (
    id_chi_tiet_hoa_don     VARCHAR(10) NOT NULL,
    id_hoa_don              VARCHAR(10) NOT NULL,
    ngay_bat_dau_bao_hanh   DATE        NULL,
    ngay_ket_thuc_bao_hanh  DATE        NULL,
    PRIMARY KEY (id_chi_tiet_hoa_don, id_hoa_don),
    FOREIGN KEY (id_hoa_don) REFERENCES Hoa_Don(id_hoa_don),
    CONSTRAINT chk_bao_hanh CHECK (ngay_ket_thuc_bao_hanh IS NULL OR ngay_ket_thuc_bao_hanh >= ngay_bat_dau_bao_hanh)
);

-- -------------------------------------------------------------
-- Bảng 12: Khach_Hang (Khách hàng)
-- Lược đồ: KhachHang(IdKhachHang, SdtKhachHang, GioiTinh, NamSinh, SoNha, TenDuong)
-- K = {id_khach_hang}
-- -------------------------------------------------------------
CREATE TABLE Khach_Hang (
    id_khach_hang       VARCHAR(10)  NOT NULL,
    sdt_khach_hang      VARCHAR(15)  NOT NULL,
    gioi_tinh           ENUM('Nam','Nữ','Khác') NOT NULL,
    nam_sinh            YEAR         NOT NULL,
    so_nha              VARCHAR(20)  NOT NULL,
    ten_duong           VARCHAR(100) NOT NULL,
    PRIMARY KEY (id_khach_hang)
);

-- -------------------------------------------------------------
-- Bảng 13: Khuyen_Mai (Khuyến mãi)
-- Lược đồ: KhuyenMai(IdKhuyenMai, IdCuaHang, TenKhuyenMai, NgayBatDau, NgayHetHan, NoiDungKhuyenMai)
-- K = {id_khuyen_mai}
-- (Bổ sung id_khuyen_mai làm khóa riêng vì 1 cửa hàng có thể có nhiều đợt KM)
-- -------------------------------------------------------------
CREATE TABLE Khuyen_Mai (
    id_khuyen_mai       VARCHAR(10)  NOT NULL,
    id_cua_hang         VARCHAR(10)  NOT NULL,
    ten_khuyen_mai      VARCHAR(100) NOT NULL,
    ngay_bat_dau        DATE         NOT NULL,
    ngay_het_han        DATE         NOT NULL,
    noi_dung_khuyen_mai TEXT         NULL,
    PRIMARY KEY (id_khuyen_mai),
    FOREIGN KEY (id_cua_hang) REFERENCES Cua_Hang(id_cua_hang),
    CONSTRAINT chk_km_date CHECK (ngay_het_han >= ngay_bat_dau)
);

-- -------------------------------------------------------------
-- Bảng 14: Thu_Ngan (Giao dịch thu ngân)
-- Lược đồ: ThuNgan(IdHoaDon, IdNhanVien, IdKhachHang, PhuongThucThanhToan, NgayThanhToan, SoTienThanhToan)
-- K = {id_hoa_don, id_nhan_vien}
-- -------------------------------------------------------------
CREATE TABLE Thu_Ngan (
    id_hoa_don              VARCHAR(10)    NOT NULL,
    id_nhan_vien            VARCHAR(10)    NOT NULL,
    id_khach_hang           VARCHAR(10)    NOT NULL,
    phuong_thuc_thanh_toan  ENUM('Tiền mặt','Thẻ ngân hàng','Ví điện tử','Chuyển khoản') NOT NULL,
    ngay_thanh_toan         DATE           NOT NULL,
    so_tien_thanh_toan      DECIMAL(15,2)  NOT NULL,
    PRIMARY KEY (id_hoa_don, id_nhan_vien),
    FOREIGN KEY (id_hoa_don)    REFERENCES Hoa_Don(id_hoa_don),
    FOREIGN KEY (id_nhan_vien)  REFERENCES Nhan_Vien(id_nhan_vien),
    FOREIGN KEY (id_khach_hang) REFERENCES Khach_Hang(id_khach_hang)
);

-- -------------------------------------------------------------
-- Bảng 15: Hang_Hoa_Ban (Hàng hóa trong chi tiết hóa đơn)
-- Lược đồ: HangHoaBan(IdHangHoaBan, IdHoaDon, IdChiTietHoaDon, SoLuongBan, IdCuaHang, GiaBan, DanhGiaNguoiDung)
-- K = {id_hang_hoa_ban, id_hoa_don, id_chi_tiet_hoa_don}
-- -------------------------------------------------------------
CREATE TABLE Hang_Hoa_Ban (
    id_hang_hoa_ban         VARCHAR(10)   NOT NULL,
    id_hoa_don              VARCHAR(10)   NOT NULL,
    id_chi_tiet_hoa_don     VARCHAR(10)   NOT NULL,
    so_luong_ban            INT           NOT NULL CHECK (so_luong_ban > 0),
    id_cua_hang             VARCHAR(10)   NOT NULL,
    gia_ban                 DECIMAL(15,2) NOT NULL,
    danh_gia_nguoi_dung     TINYINT       NULL CHECK (danh_gia_nguoi_dung BETWEEN 1 AND 5),
    PRIMARY KEY (id_hang_hoa_ban, id_hoa_don, id_chi_tiet_hoa_don),
    FOREIGN KEY (id_chi_tiet_hoa_don, id_hoa_don) REFERENCES Chi_Tiet_Hoa_Don(id_chi_tiet_hoa_don, id_hoa_don),
    FOREIGN KEY (id_cua_hang) REFERENCES Cua_Hang(id_cua_hang)
);

-- -------------------------------------------------------------
-- Bảng 16: Su_Dung (Khách hàng sử dụng khuyến mãi)
-- Lược đồ: SuDung(IdKhuyenMai, IdKhachHang, NgaySuDung)
-- K = {id_khuyen_mai, id_khach_hang}
-- -------------------------------------------------------------
CREATE TABLE Su_Dung (
    id_khuyen_mai   VARCHAR(10) NOT NULL,
    id_khach_hang   VARCHAR(10) NOT NULL,
    ngay_su_dung    DATE        NOT NULL,
    PRIMARY KEY (id_khuyen_mai, id_khach_hang),
    FOREIGN KEY (id_khuyen_mai)  REFERENCES Khuyen_Mai(id_khuyen_mai),
    FOREIGN KEY (id_khach_hang)  REFERENCES Khach_Hang(id_khach_hang)
);

-- -------------------------------------------------------------
-- Bảng 17: Danh_Gia (Đánh giá sản phẩm)
-- Lược đồ: DanhGia(IdKhachHang, IdHangHoaBan, IdChiTietHoaDon, IdHoaDon, DanhGiaChung)
-- K = {id_khach_hang, id_hang_hoa_ban, id_chi_tiet_hoa_don, id_hoa_don}
-- -------------------------------------------------------------
CREATE TABLE Danh_Gia (
    id_khach_hang           VARCHAR(10) NOT NULL,
    id_hang_hoa_ban         VARCHAR(10) NOT NULL,
    id_chi_tiet_hoa_don     VARCHAR(10) NOT NULL,
    id_hoa_don              VARCHAR(10) NOT NULL,
    danh_gia_chung          TINYINT     NOT NULL CHECK (danh_gia_chung BETWEEN 1 AND 5),
    PRIMARY KEY (id_khach_hang, id_hang_hoa_ban, id_chi_tiet_hoa_don, id_hoa_don),
    FOREIGN KEY (id_khach_hang) REFERENCES Khach_Hang(id_khach_hang),
    FOREIGN KEY (id_hang_hoa_ban, id_hoa_don, id_chi_tiet_hoa_don)
        REFERENCES Hang_Hoa_Ban(id_hang_hoa_ban, id_hoa_don, id_chi_tiet_hoa_don)
);

-- ============================================================
-- PHẦN 2: NHẬP DỮ LIỆU MẪU
-- ============================================================

-- -------------------
-- 1. KV_Cua_Hang
-- -------------------
INSERT INTO KV_Cua_Hang VALUES
('A', 'Thời trang'),
('B', 'Điện tử - Công nghệ'),
('C', 'Thực phẩm & Đồ uống'),
('D', 'Mỹ phẩm & Làm đẹp'),
('E', 'Thể thao & Giải trí');

-- -------------------
-- 2. Quan_Li_Cua_Hang
-- -------------------
INSERT INTO Quan_Li_Cua_Hang VALUES
('QL001', 5000000,  8),
('QL002', 4500000,  5),
('QL003', 6000000, 12),
('QL004', 4000000,  3),
('QL005', 5500000,  7);

-- -------------------
-- 3. Cua_Hang
-- -------------------
INSERT INTO Cua_Hang VALUES
('CH001', 'A', 'FashionZone',   'QL001'),
('CH002', 'B', 'TechWorld',     'QL002'),
('CH003', 'C', 'FoodCorner',    'QL003'),
('CH004', 'D', 'BeautyLand',    'QL004'),
('CH005', 'E', 'SportZone',     'QL005'),
('CH006', 'A', 'StyleUp',       'QL001'),
('CH007', 'B', 'GadgetHub',     'QL002');

-- -------------------
-- 4. Nhan_Vien (chèn giám sát trước)
-- -------------------
INSERT INTO Nhan_Vien VALUES
('NV001', 'Nguyễn Văn An',     8000000, 26, NULL,    'CH001'),
('NV002', 'Trần Thị Bình',     6500000, 24, 'NV001', 'CH001'),
('NV003', 'Lê Minh Cường',     7000000, 25, 'NV001', 'CH001'),
('NV004', 'Phạm Thị Dung',     9000000, 27, NULL,    'CH002'),
('NV005', 'Hoàng Văn Em',      6000000, 22, 'NV004', 'CH002'),
('NV006', 'Vũ Thị Phương',     7500000, 26, 'NV004', 'CH002'),
('NV007', 'Đặng Minh Quân',    8500000, 28, NULL,    'CH003'),
('NV008', 'Bùi Thị Hoa',       6200000, 23, 'NV007', 'CH003'),
('NV009', 'Ngô Văn Lực',       7200000, 25, 'NV007', 'CH003'),
('NV010', 'Đinh Thị Mai',      6800000, 24, NULL,    'CH004'),
('NV011', 'Lý Văn Nam',        6000000, 20, 'NV010', 'CH004'),
('NV012', 'Phan Thị Oanh',     7000000, 25, NULL,    'CH005'),
('NV013', 'Trịnh Văn Phúc',    6300000, 22, 'NV012', 'CH005'),
('NV014', 'Đỗ Thị Quyên',     6100000, 21, 'NV012', 'CH005'),
('NV015', 'Cao Văn Thắng',     8200000, 27, NULL,    'CH006');

-- -------------------
-- 5. NhanVien_SDT
-- -------------------
INSERT INTO NhanVien_SDT VALUES
('NV001', '0912345678'),
('NV002', '0923456789'),
('NV003', '0934567890'),
('NV003', '0987654321'),   -- NV003 có 2 số
('NV004', '0945678901'),
('NV005', '0956789012'),
('NV006', '0967890123'),
('NV007', '0978901234'),
('NV008', '0989012345'),
('NV009', '0990123456'),
('NV010', '0901234567'),
('NV011', '0912345670'),
('NV012', '0923456780'),
('NV013', '0934567891'),
('NV014', '0945678902'),
('NV015', '0956789013');

-- -------------------
-- 6. Nha_Cung_Cap
-- -------------------
INSERT INTO Nha_Cung_Cap VALUES
('NCC001', '0281234567', '12 Nguyễn Huệ, Q.1, TP.HCM',         'Công ty CP Thời Trang VN',    'Cao'),
('NCC002', '0242345678', '45 Trần Phú, Hà Đông, Hà Nội',        'Tập đoàn Điện Tử Á Châu',    'Rất cao'),
('NCC003', '0293456789', '78 Lê Lợi, Q.3, TP.HCM',             'Công ty Thực Phẩm Sạch',      'Trung bình'),
('NCC004', '0254567890', '23 Bạch Đằng, Hải Châu, Đà Nẵng',    'Mỹ Phẩm Thiên Nhiên',         'Cao'),
('NCC005', '0265678901', '56 Lý Thường Kiệt, Hoàn Kiếm, HN',   'Dụng Cụ Thể Thao Hùng Cường', 'Trung bình'),
('NCC006', '0276789012', '90 Điện Biên Phủ, Q.3, TP.HCM',      'Công ty TNHH Phụ Kiện Bắc',   'Thấp'),
('NCC007', '0287890123', '34 Phan Chu Trinh, Ba Đình, HN',      'Siêu Thị Nguyên Liệu Đỉnh',   'Rất cao');

-- -------------------
-- 7. Hang_Hoa
-- -------------------
INSERT INTO Hang_Hoa VALUES
('HH001', 'Áo sơ mi nam',          'Thời trang'),
('HH002', 'Quần jeans nữ',          'Thời trang'),
('HH003', 'Điện thoại Samsung A55', 'Điện tử'),
('HH004', 'Laptop Dell Inspiron',   'Điện tử'),
('HH005', 'Nước ép cam tươi 1L',    'Đồ uống'),
('HH006', 'Bánh mì sandwich',       'Thực phẩm'),
('HH007', 'Kem dưỡng da mặt',       'Mỹ phẩm'),
('HH008', 'Son môi nội địa',        'Mỹ phẩm'),
('HH009', 'Giày thể thao Adidas',   'Thể thao'),
('HH010', 'Vợt cầu lông Yonex',     'Thể thao'),
('HH011', 'Tai nghe Bluetooth',     'Điện tử'),
('HH012', 'Áo khoác dạ nữ',        'Thời trang'),
('HH013', 'Nước hoa Dior 50ml',     'Mỹ phẩm'),
('HH014', 'Bóng đá số 5',           'Thể thao'),
('HH015', 'Cà phê hòa tan G7',      'Thực phẩm');

-- -------------------
-- 8. Cung_Cap
-- -------------------
INSERT INTO Cung_Cap VALUES
('HH001', 'NCC001', '2023-01-15'),
('HH002', 'NCC001', '2023-02-20'),
('HH012','NCC001', '2023-03-10'),
('HH003', 'NCC002', '2023-06-01'),
('HH004', 'NCC002', '2023-07-15'),
('HH011', 'NCC002', '2023-08-20'),
('HH005', 'NCC003', '2024-01-05'),
('HH006', 'NCC003', '2024-02-10'),
('HH015', 'NCC003', '2024-03-01'),
('HH007', 'NCC004', '2023-04-12'),
('HH008', 'NCC004', '2023-05-18'),
('HH013', 'NCC004', '2023-09-25'),
('HH009', 'NCC005', '2023-10-08'),
('HH010', 'NCC005', '2023-11-14'),
('HH014', 'NCC005', '2023-12-20'),
('HH011', 'NCC006', '2024-01-10'),
('HH015', 'NCC007', '2024-02-15');

-- -------------------
-- 9. Giao_Dich
-- -------------------
INSERT INTO Giao_Dich VALUES
('GD001', 'HH001', 'NCC001', 'CH001', 180000,  '2024-01-10', 100),
('GD002', 'HH002', 'NCC001', 'CH001', 350000,  '2024-01-12', 80),
('GD003', 'HH012', 'NCC001', 'CH006', 550000,  '2024-02-01', 50),
('GD004', 'HH003', 'NCC002', 'CH002', 8500000, '2024-01-20', 30),
('GD005', 'HH004', 'NCC002', 'CH002', 15000000,'2024-02-05', 10),
('GD006', 'HH011', 'NCC002', 'CH007', 650000,  '2024-02-10', 60),
('GD007', 'HH005', 'NCC003', 'CH003', 15000,   '2024-03-01', 200),
('GD008', 'HH006', 'NCC003', 'CH003', 12000,   '2024-03-05', 300),
('GD009', 'HH007', 'NCC004', 'CH004', 280000,  '2024-01-25', 70),
('GD010', 'HH008', 'NCC004', 'CH004', 150000,  '2024-02-15', 120),
('GD011', 'HH009', 'NCC005', 'CH005', 900000,  '2024-03-10', 40),
('GD012', 'HH010', 'NCC005', 'CH005', 1200000, '2024-03-12', 25),
('GD013', 'HH013', 'NCC004', 'CH004', 1800000, '2024-02-20', 20),
('GD014', 'HH015', 'NCC003', 'CH003', 50000,   '2024-03-15', 150),
('GD015', 'HH014', 'NCC005', 'CH005', 200000,  '2024-03-18', 35);

-- -------------------
-- 10. Hoa_Don
-- -------------------
INSERT INTO Hoa_Don VALUES
('HD001', '2024-03-01', 2200000),
('HD002', '2024-03-02', 9500000),
('HD003', '2024-03-03', 450000),
('HD004', '2024-03-05', 16800000),
('HD005', '2024-03-07', 750000),
('HD006', '2024-03-10', 1350000),
('HD007', '2024-03-11', 3600000),
('HD008', '2024-03-12', 250000),
('HD009', '2024-03-14', 1900000),
('HD010', '2024-03-15', 580000),
('HD011', '2024-03-17', 12000000),
('HD012', '2024-03-18', 890000),
('HD013', '2024-03-20', 2700000),
('HD014', '2024-03-21', 430000),
('HD015', '2024-03-22', 5400000);

-- -------------------
-- 11. Chi_Tiet_Hoa_Don
-- -------------------
INSERT INTO Chi_Tiet_Hoa_Don VALUES
('CT001', 'HD001', '2024-03-01', '2025-03-01'),
('CT002', 'HD001', NULL, NULL),
('CT003', 'HD002', '2024-03-02', '2026-03-02'),
('CT004', 'HD003', NULL, NULL),
('CT005', 'HD004', '2024-03-05', '2026-03-05'),
('CT006', 'HD005', NULL, NULL),
('CT007', 'HD006', NULL, NULL),
('CT008', 'HD007', '2024-03-11', '2025-03-11'),
('CT009', 'HD008', NULL, NULL),
('CT010', 'HD009', NULL, NULL),
('CT011', 'HD010', NULL, NULL),
('CT012', 'HD011', '2024-03-17', '2026-03-17'),
('CT013', 'HD012', NULL, NULL),
('CT014', 'HD013', '2024-03-20', '2025-03-20'),
('CT015', 'HD014', NULL, NULL),
('CT016', 'HD015', '2024-03-22', '2026-03-22');

-- -------------------
-- 12. Khach_Hang
-- -------------------
INSERT INTO Khach_Hang VALUES
('KH001', '0912111222', 'Nam',  2000, '15',   'Nguyễn Trãi, Q.5, TP.HCM'),
('KH002', '0923222333', 'Nữ',  1998, '32',   'Lê Duẩn, Hải Châu, Đà Nẵng'),
('KH003', '0934333444', 'Nam',  1995, '7',    'Hàng Bông, Hoàn Kiếm, HN'),
('KH004', '0945444555', 'Nữ',  2001, '120',  'Trần Hưng Đạo, Q.1, TP.HCM'),
('KH005', '0956555666', 'Nam',  1990, '89',   'Lý Thái Tổ, Hoàn Kiếm, HN'),
('KH006', '0967666777', 'Nữ',  2003, '4',    'Phan Đình Phùng, Ba Đình, HN'),
('KH007', '0978777888', 'Nam',  1988, '56',   'Lê Lợi, Q.1, TP.HCM'),
('KH008', '0989888999', 'Nữ',  1997, '23',   'Điện Biên Phủ, Q.Bình Thạnh'),
('KH009', '0990999000', 'Nam',  2002, '11',   'Bạch Đằng, Ngũ Hành Sơn, ĐN'),
('KH010', '0901000111', 'Nữ',  1999, '66',   'Trung Hòa, Cầu Giấy, HN');

-- -------------------
-- 13. Khuyen_Mai
-- -------------------
INSERT INTO Khuyen_Mai VALUES
('KM001', 'CH001', 'Sale mùa hè 30%',         '2024-06-01', '2024-06-30', 'Giảm 30% toàn bộ sản phẩm thời trang mùa hè'),
('KM002', 'CH002', 'Ngày hội công nghệ',       '2024-07-15', '2024-07-17', 'Giảm 20% điện thoại, 15% laptop khi mua kèm phụ kiện'),
('KM003', 'CH003', 'Voucher ăn uống 50K',      '2024-04-01', '2024-04-30', 'Tặng voucher 50.000đ cho hóa đơn từ 200.000đ'),
('KM004', 'CH004', 'Làm đẹp mùa xuân',        '2024-03-08', '2024-03-31', 'Mua 2 tặng 1 toàn bộ son môi nhân ngày 8/3'),
('KM005', 'CH005', 'Thể thao giá rẻ',          '2024-05-01', '2024-05-31', 'Giảm 25% đồ thể thao cuối tháng'),
('KM006', 'CH006', 'Flash sale thứ 6',         '2024-03-22', '2024-03-22', 'Giảm 50% 1 giờ vàng 18h-19h thứ 6'),
('KM007', 'CH001', 'Sinh nhật khách thân thiết','2024-03-01', '2024-03-31', 'Tặng quà khách hàng sinh nhật trong tháng 3');

-- -------------------
-- 14. Thu_Ngan
-- -------------------
INSERT INTO Thu_Ngan VALUES
('HD001', 'NV002', 'KH001', 'Thẻ ngân hàng', '2024-03-01', 2200000),
('HD002', 'NV005', 'KH003', 'Tiền mặt',      '2024-03-02', 9500000),
('HD003', 'NV008', 'KH002', 'Ví điện tử',    '2024-03-03', 450000),
('HD004', 'NV005', 'KH005', 'Chuyển khoản',  '2024-03-05', 16800000),
('HD005', 'NV011', 'KH004', 'Tiền mặt',      '2024-03-07', 750000),
('HD006', 'NV002', 'KH006', 'Ví điện tử',    '2024-03-10', 1350000),
('HD007', 'NV013', 'KH007', 'Thẻ ngân hàng', '2024-03-11', 3600000),
('HD008', 'NV008', 'KH008', 'Tiền mặt',      '2024-03-12', 250000),
('HD009', 'NV011', 'KH009', 'Ví điện tử',    '2024-03-14', 1900000),
('HD010', 'NV003', 'KH001', 'Tiền mặt',      '2024-03-15', 580000),
('HD011', 'NV005', 'KH003', 'Chuyển khoản',  '2024-03-17', 12000000),
('HD012', 'NV008', 'KH010', 'Tiền mặt',      '2024-03-18', 890000),
('HD013', 'NV002', 'KH007', 'Thẻ ngân hàng', '2024-03-20', 2700000),
('HD014', 'NV013', 'KH002', 'Ví điện tử',    '2024-03-21', 430000),
('HD015', 'NV005', 'KH005', 'Chuyển khoản',  '2024-03-22', 5400000);

-- -------------------
-- 15. Hang_Hoa_Ban
-- -------------------
INSERT INTO Hang_Hoa_Ban VALUES
('HHB001', 'HD001', 'CT001', 2, 'CH001', 900000,   4),
('HHB002', 'HD001', 'CT002', 1, 'CH001', 400000,   5),
('HHB003', 'HD002', 'CT003', 1, 'CH002', 9500000,  4),
('HHB004', 'HD003', 'CT004', 3, 'CH003', 30000,    3),
('HHB005', 'HD003', 'CT004', 5, 'CH003', 18000,    4),
('HHB006', 'HD004', 'CT005', 1, 'CH002', 16800000, 5),
('HHB007', 'HD005', 'CT006', 2, 'CH004', 280000,   4),
('HHB008', 'HD005', 'CT006', 1, 'CH004', 190000,   3),
('HHB009', 'HD006', 'CT007', 3, 'CH001', 450000,   5),
('HHB010', 'HD007', 'CT008', 4, 'CH005', 900000,   4),
('HHB011', 'HD008', 'CT009', 5, 'CH003', 50000,    4),
('HHB012', 'HD009', 'CT010', 2, 'CH004', 800000,   5),
('HHB013', 'HD010', 'CT011', 2, 'CH001', 290000,   3),
('HHB014', 'HD011', 'CT012', 1, 'CH002', 12000000, 5),
('HHB015', 'HD012', 'CT013', 3, 'CH004', 280000,   4),
('HHB016', 'HD013', 'CT014', 2, 'CH001', 1200000,  5),
('HHB017', 'HD014', 'CT015', 5, 'CH003', 86000,    4),
('HHB018', 'HD015', 'CT016', 1, 'CH002', 5400000,  5);

-- -------------------
-- 16. Su_Dung
-- -------------------
INSERT INTO Su_Dung VALUES
('KM001', 'KH001', '2024-06-10'),
('KM001', 'KH003', '2024-06-15'),
('KM002', 'KH003', '2024-07-16'),
('KM002', 'KH005', '2024-07-17'),
('KM003', 'KH002', '2024-04-05'),
('KM003', 'KH008', '2024-04-18'),
('KM004', 'KH004', '2024-03-09'),
('KM004', 'KH006', '2024-03-10'),
('KM005', 'KH007', '2024-05-15'),
('KM006', 'KH001', '2024-03-22'),
('KM007', 'KH001', '2024-03-05'),
('KM007', 'KH007', '2024-03-22');

-- -------------------
-- 17. Danh_Gia
-- -------------------
INSERT INTO Danh_Gia VALUES
('KH001', 'HHB001', 'CT001', 'HD001', 4),
('KH001', 'HHB002', 'CT002', 'HD001', 5),
('KH003', 'HHB003', 'CT003', 'HD002', 4),
('KH002', 'HHB004', 'CT004', 'HD003', 3),
('KH002', 'HHB005', 'CT004', 'HD003', 4),
('KH005', 'HHB006', 'CT005', 'HD004', 5),
('KH004', 'HHB007', 'CT006', 'HD005', 4),
('KH006', 'HHB009', 'CT007', 'HD006', 5),
('KH007', 'HHB010', 'CT008', 'HD007', 4),
('KH003', 'HHB014', 'CT012', 'HD011', 5),
('KH010', 'HHB015', 'CT013', 'HD012', 4),
('KH007', 'HHB016', 'CT014', 'HD013', 5),
('KH005', 'HHB018', 'CT016', 'HD015', 5);

-- ============================================================
-- PHẦN 3: CÁC CÂU TRUY VẤN
-- ============================================================

-- -------------------------------------------------------
-- Truy vấn 1: Danh sách nhân viên kèm thông tin cửa hàng và tên giám sát
-- -------------------------------------------------------
SELECT
    nv.id_nhan_vien,
    nv.ten_nhan_vien,
    nv.luong,
    nv.so_ngay_lam,
    gs.ten_nhan_vien AS ten_giam_sat,
    ch.ten_shop,
    kv.loai_cua_hang
FROM Nhan_Vien nv
JOIN Cua_Hang ch ON nv.id_cua_hang = ch.id_cua_hang
JOIN KV_Cua_Hang kv ON ch.khu_vuc = kv.khu_vuc
LEFT JOIN Nhan_Vien gs ON nv.id_giam_sat = gs.id_nhan_vien
ORDER BY ch.id_cua_hang, nv.id_nhan_vien;

-- -------------------------------------------------------
-- Truy vấn 2: Tổng doanh thu theo từng cửa hàng trong tháng 3/2024
-- -------------------------------------------------------
SELECT
    ch.id_cua_hang,
    ch.ten_shop,
    kv.loai_cua_hang,
    COUNT(DISTINCT tn.id_hoa_don)   AS so_hoa_don,
    SUM(tn.so_tien_thanh_toan)       AS tong_doanh_thu
FROM Thu_Ngan tn
JOIN Hoa_Don hd    ON tn.id_hoa_don = hd.id_hoa_don
JOIN Hang_Hoa_Ban hhb ON hhb.id_hoa_don = hd.id_hoa_don
JOIN Cua_Hang ch   ON hhb.id_cua_hang = ch.id_cua_hang
JOIN KV_Cua_Hang kv ON ch.khu_vuc = kv.khu_vuc
WHERE MONTH(hd.ngay_lap) = 3 AND YEAR(hd.ngay_lap) = 2024
GROUP BY ch.id_cua_hang, ch.ten_shop, kv.loai_cua_hang
ORDER BY tong_doanh_thu DESC;

-- -------------------------------------------------------
-- Truy vấn 3: Top 5 khách hàng chi tiêu nhiều nhất
-- -------------------------------------------------------
SELECT
    kh.id_khach_hang,
    kh.sdt_khach_hang,
    kh.gioi_tinh,
    kh.nam_sinh,
    COUNT(DISTINCT tn.id_hoa_don)   AS so_lan_mua,
    SUM(tn.so_tien_thanh_toan)      AS tong_chi_tieu
FROM Khach_Hang kh
JOIN Thu_Ngan tn ON kh.id_khach_hang = tn.id_khach_hang
GROUP BY kh.id_khach_hang, kh.sdt_khach_hang, kh.gioi_tinh, kh.nam_sinh
ORDER BY tong_chi_tieu DESC
LIMIT 5;

-- -------------------------------------------------------
-- Truy vấn 4: Hàng hóa chưa bán được lần nào
-- -------------------------------------------------------
SELECT hh.id_hang_hoa, hh.ten_hang_hoa, hh.loai_hang_hoa
FROM Hang_Hoa hh
WHERE hh.id_hang_hoa NOT IN (
    SELECT DISTINCT gd.id_hang_hoa FROM Giao_Dich gd
    JOIN Hang_Hoa_Ban hhb ON gd.shop_id = hhb.id_cua_hang
);

-- -------------------------------------------------------
-- Truy vấn 5: Nhân viên có lương cao hơn lương trung bình của cửa hàng mình
-- -------------------------------------------------------
SELECT
    nv.id_nhan_vien,
    nv.ten_nhan_vien,
    nv.luong,
    ch.ten_shop,
    tb.luong_tb_cua_hang
FROM Nhan_Vien nv
JOIN Cua_Hang ch ON nv.id_cua_hang = ch.id_cua_hang
JOIN (
    SELECT id_cua_hang, AVG(luong) AS luong_tb_cua_hang
    FROM Nhan_Vien
    GROUP BY id_cua_hang
) tb ON nv.id_cua_hang = tb.id_cua_hang
WHERE nv.luong > tb.luong_tb_cua_hang
ORDER BY ch.ten_shop, nv.luong DESC;

-- -------------------------------------------------------
-- Truy vấn 6: Khuyến mãi đang còn hiệu lực (tính đến ngày hiện tại)
--             kèm số lượng khách hàng đã sử dụng
-- -------------------------------------------------------
SELECT
    km.id_khuyen_mai,
    km.ten_khuyen_mai,
    ch.ten_shop,
    km.ngay_bat_dau,
    km.ngay_het_han,
    COUNT(sd.id_khach_hang) AS so_kh_su_dung
FROM Khuyen_Mai km
JOIN Cua_Hang ch ON km.id_cua_hang = ch.id_cua_hang
LEFT JOIN Su_Dung sd ON km.id_khuyen_mai = sd.id_khuyen_mai
WHERE km.ngay_het_han >= CURDATE()
GROUP BY km.id_khuyen_mai, km.ten_khuyen_mai, ch.ten_shop, km.ngay_bat_dau, km.ngay_het_han
ORDER BY km.ngay_het_han;

-- -------------------------------------------------------
-- Truy vấn 7: Thống kê đánh giá trung bình của từng loại hàng hóa
-- -------------------------------------------------------
SELECT
    hh.loai_hang_hoa,
    COUNT(DISTINCT hh.id_hang_hoa)  AS so_loai_san_pham,
    COUNT(dg.id_khach_hang)          AS so_luot_danh_gia,
    ROUND(AVG(dg.danh_gia_chung), 2) AS diem_tb
FROM Hang_Hoa_Ban hhb
JOIN Giao_Dich gd2 ON hhb.id_cua_hang = gd2.shop_id
JOIN Hang_Hoa hh   ON gd2.id_hang_hoa = hh.id_hang_hoa
JOIN Danh_Gia dg   ON hhb.id_hang_hoa_ban = dg.id_hang_hoa_ban
                   AND hhb.id_hoa_don     = dg.id_hoa_don
                   AND hhb.id_chi_tiet_hoa_don = dg.id_chi_tiet_hoa_don
GROUP BY hh.loai_hang_hoa
ORDER BY diem_tb DESC;

-- -------------------------------------------------------
-- Truy vấn 8: Nhà cung cấp cung cấp nhiều loại hàng nhất
-- -------------------------------------------------------
SELECT
    ncc.id_nha_cung_cap,
    ncc.ten_nha_cung_cap,
    ncc.muc_do_noi_tieng,
    COUNT(DISTINCT cc.id_hang_hoa) AS so_loai_hang_cung_cap,
    SUM(gd.so_luong)               AS tong_so_luong_nhap
FROM Nha_Cung_Cap ncc
JOIN Cung_Cap cc ON ncc.id_nha_cung_cap = cc.id_nha_cung_cap
JOIN Giao_Dich gd ON ncc.id_nha_cung_cap = gd.id_nha_cung_cap
GROUP BY ncc.id_nha_cung_cap, ncc.ten_nha_cung_cap, ncc.muc_do_noi_tieng
ORDER BY so_loai_hang_cung_cap DESC, tong_so_luong_nhap DESC;

-- -------------------------------------------------------
-- Truy vấn 9: Hóa đơn có tổng giá trị lớn nhất theo từng phương thức thanh toán
-- -------------------------------------------------------
SELECT
    tn.phuong_thuc_thanh_toan,
    COUNT(*) AS so_giao_dich,
    MAX(tn.so_tien_thanh_toan)  AS gia_tri_cao_nhat,
    MIN(tn.so_tien_thanh_toan)  AS gia_tri_thap_nhat,
    ROUND(AVG(tn.so_tien_thanh_toan), 0) AS gia_tri_trung_binh,
    SUM(tn.so_tien_thanh_toan)  AS tong_doanh_thu
FROM Thu_Ngan tn
GROUP BY tn.phuong_thuc_thanh_toan
ORDER BY tong_doanh_thu DESC;

-- -------------------------------------------------------
-- Truy vấn 10: Danh sách khách hàng mua hàng nhưng chưa đánh giá bất kỳ sản phẩm nào
-- -------------------------------------------------------
SELECT DISTINCT
    kh.id_khach_hang,
    kh.sdt_khach_hang,
    kh.gioi_tinh,
    kh.nam_sinh
FROM Khach_Hang kh
JOIN Thu_Ngan tn ON kh.id_khach_hang = tn.id_khach_hang
WHERE kh.id_khach_hang NOT IN (
    SELECT DISTINCT id_khach_hang FROM Danh_Gia
)
ORDER BY kh.id_khach_hang;

-- -------------------------------------------------------
-- Truy vấn 11: Kiểm tra bảo hành còn hiệu lực của từng hóa đơn
-- -------------------------------------------------------
SELECT
    hd.id_hoa_don,
    hd.ngay_lap,
    ct.id_chi_tiet_hoa_don,
    ct.ngay_bat_dau_bao_hanh,
    ct.ngay_ket_thuc_bao_hanh,
    CASE
        WHEN ct.ngay_ket_thuc_bao_hanh IS NULL THEN 'Không có bảo hành'
        WHEN ct.ngay_ket_thuc_bao_hanh >= CURDATE() THEN 'Còn bảo hành'
        ELSE 'Hết bảo hành'
    END AS tinh_trang_bao_hanh
FROM Hoa_Don hd
JOIN Chi_Tiet_Hoa_Don ct ON hd.id_hoa_don = ct.id_hoa_don
ORDER BY hd.id_hoa_don, ct.id_chi_tiet_hoa_don;

-- -------------------------------------------------------
-- Truy vấn 12: Báo cáo tổng hợp theo quản lý cửa hàng
-- -------------------------------------------------------
SELECT
    ql.id_quan_li,
    ql.tham_nien_quan_li,
    ql.thuong_chuc_vu,
    GROUP_CONCAT(ch.ten_shop SEPARATOR ', ') AS danh_sach_cua_hang,
    COUNT(DISTINCT nv.id_nhan_vien)           AS tong_nhan_vien,
    ROUND(AVG(nv.luong), 0)                   AS luong_nv_trung_binh
FROM Quan_Li_Cua_Hang ql
JOIN Cua_Hang ch ON ql.id_quan_li = ch.id_quan_li
LEFT JOIN Nhan_Vien nv ON ch.id_cua_hang = nv.id_cua_hang
GROUP BY ql.id_quan_li, ql.tham_nien_quan_li, ql.thuong_chuc_vu
ORDER BY tong_nhan_vien DESC;
