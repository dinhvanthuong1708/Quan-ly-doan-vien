CREATE DATABASE QLDoanVien;
USE QLDoanVien;

-- Tạo bảng DoanVien
CREATE TABLE DoanVien (
    MaDoanVien INT PRIMARY KEY,
    HoTen NVARCHAR(100) NOT NULL,
    NgaySinh DATE NOT NULL,
    GioiTinh NVARCHAR(10) CHECK (GioiTinh IN (N'Nam', N'Nữ')),
    DiaChi NVARCHAR(255),
    SoDienThoai VARCHAR(15),
    Email NVARCHAR(100),
    NgayVaoDoan DATE NOT NULL,
    TrangThai NVARCHAR(20) CHECK (TrangThai IN (N'Hoạt động', N'Không hoạt động'))
);
GO

-- Tạo bảng ChiDoan
CREATE TABLE ChiDoan (
    MaChiDoan INT PRIMARY KEY,
    TenChiDoan NVARCHAR(100) NOT NULL,
    NgayThanhLap DATE NOT NULL,
    SoLuongDoanVien INT DEFAULT 0,
    BiThuDoanVienID INT,
    FOREIGN KEY (BiThuDoanVienID) REFERENCES DoanVien(MaDoanVien)
);
GO

-- Tạo bảng HoatDong
CREATE TABLE HoatDong (
    MaHoatDong INT PRIMARY KEY,
    TenHoatDong NVARCHAR(255) NOT NULL,
    NgayToChuc DATE NOT NULL,
    DiaDiem NVARCHAR(255) NOT NULL,
    MoTa NVARCHAR(1000),
    MaChiDoan INT,
    FOREIGN KEY (MaChiDoan) REFERENCES ChiDoan(MaChiDoan)
);
GO

-- Tạo bảng ThamGiaHoatDong
CREATE TABLE ThamGiaHoatDong (
    MaDoanVien INT, 
    MaHoatDong INT,
    VaiTro NVARCHAR(100) CHECK (VaiTro IN (N'Thành viên', N'Ban tổ chức', N'Tình nguyện viên')),
    DiemRenLuyen INT CHECK (DiemRenLuyen BETWEEN 0 AND 100),
    PRIMARY KEY (MaDoanVien, MaHoatDong),
    FOREIGN KEY (MaDoanVien) REFERENCES DoanVien(MaDoanVien) ON DELETE CASCADE,
    FOREIGN KEY (MaHoatDong) REFERENCES HoatDong(MaHoatDong) ON DELETE CASCADE
);
GO

-- Tạo bảng KhenThuongKyLuat
CREATE TABLE KhenThuongKyLuat (
    MaKhenThuong INT PRIMARY KEY,
    MaDoanVien INT NOT NULL,
    Loai NVARCHAR(50) CHECK (Loai IN (N'Khen thưởng', N'Kỷ luật')) NOT NULL,
    MoTa NVARCHAR(1000) NOT NULL,
    NgayQuyetDinh DATE NOT NULL,
    CapQuyetDinh NVARCHAR(255) NOT NULL,
    FOREIGN KEY (MaDoanVien) REFERENCES DoanVien(MaDoanVien) ON DELETE CASCADE
);
GO

-- Tạo bảng DongGopDoanPhi
CREATE TABLE DongGopDoanPhi (
    MaGiaoDich INT PRIMARY KEY,
    MaDoanVien INT NOT NULL,
    SoTien DECIMAL(10,2) NOT NULL CHECK (SoTien >= 0),
    NgayDong DATE NOT NULL,
    NamHoc VARCHAR(10) NOT NULL,
    TrangThai NVARCHAR(50) CHECK (TrangThai IN (N'Đã đóng', N'Chưa đóng')) NOT NULL,
    FOREIGN KEY (MaDoanVien) REFERENCES DoanVien(MaDoanVien) ON DELETE CASCADE
);
GO

-- Chèn dữ liệu vào bảng DoanVien
INSERT INTO DoanVien (MaDoanVien, HoTen, NgaySinh, GioiTinh, DiaChi, SoDienThoai, Email, NgayVaoDoan, TrangThai)
VALUES 
    (1, N'Nguyễn Văn An', '2000-05-15', N'Nam', N'123 Nguyễn Trãi, Hà Nội', '0912345678', 'an.nguyen@gmail.com', '2018-03-26', N'Hoạt động'),
    (2, N'Trần Thị Bình', '2001-08-23', N'Nữ', N'45 Lê Lợi, Hồ Chí Minh', '0923456789', 'binh.tran@gmail.com', '2019-04-15', N'Hoạt động'),
    (3, N'Lê Văn Cường', '2002-01-10', N'Nam', N'67 Trần Phú, Đà Nẵng', '0934567890', 'cuong.le@gmail.com', '2020-05-19', N'Không hoạt động');

-- Chèn dữ liệu vào bảng ChiDoan
INSERT INTO ChiDoan (MaChiDoan, TenChiDoan, NgayThanhLap, SoLuongDoanVien, BiThuDoanVienID)
VALUES 
    (101, N'Chi đoàn Khoa CNTT', '2015-09-01', 25, 1),
    (102, N'Chi đoàn Khoa Kinh tế', '2016-08-15', 30, 2),
    (103, N'Chi đoàn Khoa Ngoại ngữ', '2016-10-20', 22, 3);

-- Chèn dữ liệu vào bảng HoatDong
INSERT INTO HoatDong (MaHoatDong, TenHoatDong, NgayToChuc, DiaDiem, MoTa, MaChiDoan)
VALUES 
    (201, N'Hiến máu tình nguyện', '2023-06-15', N'Hội trường A', N'Chương trình hiến máu nhân đạo hàng năm', 101),
    (202, N'Mùa hè xanh', '2023-07-10', N'Xã Tân Phú, Hà Nội', N'Chiến dịch tình nguyện mùa hè', 102),
    (203, N'Chào tân sinh viên', '2023-09-05', N'Sân trường', N'Chương trình chào đón tân sinh viên khóa 2023', 103);

-- Chèn dữ liệu vào bảng ThamGiaHoatDong
INSERT INTO ThamGiaHoatDong (MaDoanVien, MaHoatDong, VaiTro, DiemRenLuyen)
VALUES 
    (1, 201, N'Ban tổ chức', 90),
    (2, 202, N'Tình nguyện viên', 85),
    (3, 203, N'Thành viên', 75);

-- Chèn dữ liệu vào bảng KhenThuongKyLuat
INSERT INTO KhenThuongKyLuat (MaKhenThuong, MaDoanVien, Loai, MoTa, NgayQuyetDinh, CapQuyetDinh)
VALUES 
    (301, 1, N'Khen thưởng', N'Hoàn thành xuất sắc nhiệm vụ năm học 2022-2023', '2023-06-30', N'Đoàn trường'),
    (302, 2, N'Khen thưởng', N'Đóng góp tích cực cho hoạt động tình nguyện', '2023-08-15', N'Chi đoàn'),
    (303, 3, N'Kỷ luật', N'Tham gia không đầy đủ các hoạt động bắt buộc', '2023-05-20', N'Chi đoàn');

-- Chèn dữ liệu vào bảng DongGopDoanPhi
INSERT INTO DongGopDoanPhi (MaGiaoDich, MaDoanVien, SoTien, NgayDong, NamHoc, TrangThai)
VALUES 
    (401, 1, 50000, '2023-01-15', '2022-2023', N'Đã đóng'),
    (402, 2, 50000, '2023-01-20', '2022-2023', N'Đã đóng'),
    (403, 3, 50000, '2023-02-10', '2022-2023', N'Đã đóng');


SELECT * FROM DoanVien;
SELECT * FROM ChiDoan;
SELECT * FROM HoatDong;
SELECT * FROM ThamGiaHoatDong;
SELECT * FROM KhenThuongKyLuat;
SELECT * FROM DongGopDoanPhi;

--Truy vấn cơ bản
-- 1. Cập nhật số điện thoại của đoàn viên có mã là 1
UPDATE DoanVien
SET SoDienThoai = '0911111111'
WHERE MaDoanVien = 1;

-- 2. Cập nhật điểm rèn luyện của đoàn viên tham gia hoạt động 201
UPDATE ThamGiaHoatDong
SET DiemRenLuyen = 95
WHERE MaHoatDong = 201 AND MaDoanVien = 1;

-- 1. Xóa khen thưởng kỷ luật có mã là 303
DELETE FROM KhenThuongKyLuat
WHERE MaKhenThuong = 303;

-- 2. Xóa hoạt động có mã là 203 và các thông tin liên quan
DELETE FROM ThamGiaHoatDong
WHERE MaHoatDong = 203;

DELETE FROM HoatDong
WHERE MaHoatDong = 203;