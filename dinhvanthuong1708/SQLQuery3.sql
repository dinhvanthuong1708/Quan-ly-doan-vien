USE QLDoanVien;

----**Tạo 7- 10 view từ cơ bản đến nâng cao
-- 1. View cơ bản: Danh sách đoàn viên đang hoạt động
CREATE VIEW vw_DoanVienHoatDong AS
SELECT MaDoanVien, HoTen, NgaySinh, GioiTinh, NgayVaoDoan
FROM DoanVien
WHERE TrangThai = N'Hoạt động';
GO

SELECT * FROM vw_DoanVienHoatDong;
GO 

-- 2. View cơ bản: Thông tin chi đoàn và bí thư
CREATE VIEW vw_ThongTinChiDoan AS
SELECT cd.MaChiDoan, cd.TenChiDoan, cd.NgayThanhLap, cd.SoLuongDoanVien,
       dv.HoTen AS BiThu, dv.SoDienThoai AS SDTBiThu
FROM ChiDoan cd
JOIN DoanVien dv ON cd.BiThuDoanVienID = dv.MaDoanVien;
GO

SELECT * FROM vw_ThongTinChiDoan;
GO

-- 3. View trung bình: Thống kê hoạt động theo chi đoàn
CREATE VIEW vw_ThongKeHoatDong AS
SELECT cd.MaChiDoan, cd.TenChiDoan, COUNT(hd.MaHoatDong) AS SoLuongHoatDong
FROM ChiDoan cd
LEFT JOIN HoatDong hd ON cd.MaChiDoan = hd.MaChiDoan
GROUP BY cd.MaChiDoan, cd.TenChiDoan;
GO

SELECT * FROM vw_ThongKeHoatDong;
GO

-- 4. View trung bình: Đoàn phí theo đoàn viên và năm học
CREATE VIEW vw_DoanPhiTheoNam AS
SELECT dv.MaDoanVien, dv.HoTen, dp.NamHoc, SUM(dp.SoTien) AS TongDoanPhi
FROM DoanVien dv
JOIN DongGopDoanPhi dp ON dv.MaDoanVien = dp.MaDoanVien
GROUP BY dv.MaDoanVien, dv.HoTen, dp.NamHoc;
GO

SELECT * FROM vw_DoanPhiTheoNam;
GO

-- 5. View nâng cao: Điểm rèn luyện trung bình của đoàn viên
CREATE VIEW vw_DiemRenLuyen AS
SELECT dv.MaDoanVien, dv.HoTen, 
       AVG(tg.DiemRenLuyen) AS DiemTrungBinh,
       COUNT(tg.MaHoatDong) AS SoHoatDongThamGia
FROM DoanVien dv
LEFT JOIN ThamGiaHoatDong tg ON dv.MaDoanVien = tg.MaDoanVien
GROUP BY dv.MaDoanVien, dv.HoTen;
GO

SELECT * FROM vw_DiemRenLuyen;
GO

-- 6. View nâng cao: Thống kê khen thưởng, kỷ luật theo đoàn viên
CREATE VIEW vw_ThongKeKhenThuongKyLuat AS
SELECT dv.MaDoanVien, dv.HoTen,
       SUM(CASE WHEN kt.Loai = N'Khen thưởng' THEN 1 ELSE 0 END) AS SoLanKhenThuong,
       SUM(CASE WHEN kt.Loai = N'Kỷ luật' THEN 1 ELSE 0 END) AS SoLanKyLuat
FROM DoanVien dv
LEFT JOIN KhenThuongKyLuat kt ON dv.MaDoanVien = kt.MaDoanVien
GROUP BY dv.MaDoanVien, dv.HoTen;
GO

SELECT * FROM vw_ThongKeKhenThuongKyLuat;
GO

-- 7. View nâng cao: Báo cáo tổng hợp hoạt động đoàn viên
CREATE VIEW vw_BaoCaoTongHop AS
SELECT dv.MaDoanVien, dv.HoTen, dv.NgayVaoDoan, dv.TrangThai,
       cd.TenChiDoan,
       COUNT(DISTINCT tg.MaHoatDong) AS SoHoatDong,
       AVG(tg.DiemRenLuyen) AS DiemTrungBinh,
       SUM(CASE WHEN kt.Loai = N'Khen thưởng' THEN 1 ELSE 0 END) AS SoKhenThuong,
       SUM(CASE WHEN kt.Loai = N'Kỷ luật' THEN 1 ELSE 0 END) AS SoKyLuat,
       SUM(dp.SoTien) AS TongDoanPhi
FROM DoanVien dv
LEFT JOIN ChiDoan cd ON cd.BiThuDoanVienID = dv.MaDoanVien
LEFT JOIN ThamGiaHoatDong tg ON dv.MaDoanVien = tg.MaDoanVien
LEFT JOIN KhenThuongKyLuat kt ON dv.MaDoanVien = kt.MaDoanVien
LEFT JOIN DongGopDoanPhi dp ON dv.MaDoanVien = dp.MaDoanVien
GROUP BY dv.MaDoanVien, dv.HoTen, dv.NgayVaoDoan, dv.TrangThai, cd.TenChiDoan;
GO

SELECT * FROM vw_BaoCaoTongHop;
GO



----**Tạo 7-10 index cần thiết cho các bảng
-- 1. Index cho bảng DoanVien - tìm kiếm theo Họ Tên
CREATE INDEX IX_DoanVien_HoTen ON DoanVien(HoTen);
GO

SELECT * FROM sys.indexes WHERE name = 'IX_DoanVien_HoTen';
GO

-- 2. Index cho bảng DoanVien - tìm kiếm theo trạng thái
CREATE INDEX IX_DoanVien_TrangThai ON DoanVien(TrangThai);
GO

SELECT * FROM sys.indexes WHERE name = 'IX_DoanVien_TrangThai';
GO

-- 3. Index cho bảng DongGopDoanPhi - tìm kiếm và phân tích theo năm học
CREATE INDEX IX_DongGopDoanPhi_NamHoc ON DongGopDoanPhi(NamHoc);
GO

SELECT * FROM sys.indexes WHERE name = 'IX_DongGopDoanPhi_NamHoc';
GO

-- 4. Index tổng hợp cho bảng HoatDong - tối ưu truy vấn theo chi đoàn và ngày tổ chức
CREATE INDEX IX_HoatDong_ChiDoan_NgayToChuc ON HoatDong(MaChiDoan, NgayToChuc);
GO

SELECT * FROM sys.indexes WHERE name = 'IX_HoatDong_ChiDoan_NgayToChuc';
GO

-- 5. Index cho bảng KhenThuongKyLuat - phân tích theo loại
CREATE INDEX IX_KhenThuongKyLuat_Loai ON KhenThuongKyLuat(Loai);
GO

SELECT * FROM sys.indexes WHERE name = 'IX_KhenThuongKyLuat_Loai';
GO

-- 6. Index tổng hợp cho bảng ThamGiaHoatDong - phân tích theo vai trò và điểm
CREATE INDEX IX_ThamGiaHoatDong_VaiTro_DiemRL ON ThamGiaHoatDong(VaiTro, DiemRenLuyen);
GO

SELECT * FROM sys.indexes WHERE name = 'IX_ThamGiaHoatDong_VaiTro_DiemRL';
GO

-- 7. Index cho việc tìm kiếm nhanh đoàn viên theo ngày vào đoàn
CREATE INDEX IX_DoanVien_NgayVaoDoan ON DoanVien(NgayVaoDoan);
GO

SELECT * FROM sys.indexes WHERE name = 'IX_DoanVien_NgayVaoDoan';
GO



----**Xây dựng 10 Stored Procedure(không tham số, có tham số, có OUTPUT)
-- 1. SP không tham số: Hiển thị danh sách đoàn viên đang hoạt động
CREATE PROCEDURE sp_DanhSachDoanVienHoatDong
AS
BEGIN
    SELECT MaDoanVien, HoTen, NgaySinh, GioiTinh, NgayVaoDoan, SoDienThoai
    FROM DoanVien
    WHERE TrangThai = N'Hoạt động'
    ORDER BY HoTen
END
GO

EXEC sp_DanhSachDoanVienHoatDong
GO

-- 2. SP không tham số: Thống kê số lượng đoàn viên theo chi đoàn
CREATE OR ALTER PROCEDURE sp_ThongKeDoanVienTheoChiDoan
AS
BEGIN
    SELECT cd.MaChiDoan, cd.TenChiDoan, cd.SoLuongDoanVien
    FROM ChiDoan cd
    ORDER BY cd.SoLuongDoanVien DESC
END
GO

EXEC sp_ThongKeDoanVienTheoChiDoan
GO

-- 3. SP có tham số: Thêm đoàn viên mới
CREATE OR ALTER PROCEDURE sp_ThemDoanVien
    @MaDoanVien INT,
    @HoTen NVARCHAR(100),
    @NgaySinh DATE,
    @GioiTinh NVARCHAR(10),
    @DiaChi NVARCHAR(255),
    @SoDienThoai VARCHAR(15),
    @Email NVARCHAR(100),
    @NgayVaoDoan DATE,
    @TrangThai NVARCHAR(20)
AS
BEGIN
    INSERT INTO DoanVien(MaDoanVien, HoTen, NgaySinh, GioiTinh, DiaChi, SoDienThoai, Email, NgayVaoDoan, TrangThai)
    VALUES(@MaDoanVien, @HoTen, @NgaySinh, @GioiTinh, @DiaChi, @SoDienThoai, @Email, @NgayVaoDoan, @TrangThai)
END
GO

EXEC sp_ThemDoanVien 5, N'Đỗ Thị Hương', '2002-07-15', N'Nữ', N'55 Quang Trung, Đà Nẵng', '0912345678', 'huong.do@gmail.com', '2020-10-18', N'Hoạt động'
GO

-- 4. SP có tham số: Tìm kiếm đoàn viên theo tên
CREATE PROCEDURE sp_TimKiemDoanVien
    @HoTen NVARCHAR(100)
AS
BEGIN
    SELECT MaDoanVien, HoTen, NgaySinh, GioiTinh, DiaChi, SoDienThoai, Email, NgayVaoDoan
    FROM DoanVien
    WHERE HoTen LIKE N'%' + @HoTen + N'%'
END
GO

EXEC sp_TimKiemDoanVien N'Nguyễn'
GO

-- 5. SP có tham số: Đăng ký tham gia hoạt động
CREATE PROCEDURE sp_DangKyThamGiaHoatDong
    @MaDoanVien INT,
    @MaHoatDong INT,
    @VaiTro NVARCHAR(100)
AS
BEGIN
    INSERT INTO ThamGiaHoatDong(MaDoanVien, MaHoatDong, VaiTro, DiemRenLuyen)
    VALUES(@MaDoanVien, @MaHoatDong, @VaiTro, NULL)
END
GO

EXEC sp_DangKyThamGiaHoatDong 1, 202, N'Tình nguyện viên'
GO

-- 6. SP có tham số đầu ra: Lấy thông tin chi tiết đoàn viên
CREATE PROCEDURE sp_LayThongTinDoanVien
    @MaDoanVien INT,
    @HoTen NVARCHAR(100) OUTPUT,
    @NgaySinh DATE OUTPUT,
    @SoDienThoai VARCHAR(15) OUTPUT,
    @TrangThai NVARCHAR(20) OUTPUT
AS
BEGIN
    SELECT @HoTen = HoTen, @NgaySinh = NgaySinh, @SoDienThoai = SoDienThoai, @TrangThai = TrangThai
    FROM DoanVien
    WHERE MaDoanVien = @MaDoanVien
END
GO

DECLARE @HoTen NVARCHAR(100), @NgaySinh DATE, @SoDienThoai VARCHAR(15), @TrangThai NVARCHAR(20)
EXEC sp_LayThongTinDoanVien 1, @HoTen OUTPUT, @NgaySinh OUTPUT, @SoDienThoai OUTPUT, @TrangThai OUTPUT
SELECT @HoTen AS HoTen, @NgaySinh AS NgaySinh, @SoDienThoai AS SoDienThoai, @TrangThai AS TrangThai
GO

-- 7. SP có tham số đầu ra: Tính điểm rèn luyện trung bình
CREATE PROCEDURE sp_TinhDiemRenLuyen
    @MaDoanVien INT,
    @DiemTrungBinh FLOAT OUTPUT,
    @SoHoatDong INT OUTPUT
AS
BEGIN
    SELECT @DiemTrungBinh = AVG(CAST(DiemRenLuyen AS FLOAT)), @SoHoatDong = COUNT(*)
    FROM ThamGiaHoatDong
    WHERE MaDoanVien = @MaDoanVien AND DiemRenLuyen IS NOT NULL
END
GO

DECLARE @DiemTB FLOAT, @SoHD INT
EXEC sp_TinhDiemRenLuyen 1, @DiemTB OUTPUT, @SoHD OUTPUT
SELECT @DiemTB AS DiemTrungBinh, @SoHD AS SoHoatDong
GO

-- 8. SP có tham số và trả về kết quả: Cập nhật đoàn phí
CREATE PROCEDURE sp_CapNhatDoanPhi
    @MaDoanVien INT,
    @NamHoc VARCHAR(10),
    @SoTien DECIMAL(10,2)
AS
BEGIN
    DECLARE @MaGiaoDich INT
    SELECT @MaGiaoDich = MAX(MaGiaoDich) + 1 FROM DongGopDoanPhi
    
    INSERT INTO DongGopDoanPhi(MaGiaoDich, MaDoanVien, SoTien, NgayDong, NamHoc, TrangThai)
    VALUES(@MaGiaoDich, @MaDoanVien, @SoTien, GETDATE(), @NamHoc, N'Đã đóng')
    SELECT * FROM DongGopDoanPhi WHERE MaGiaoDich = @MaGiaoDich
END
GO

EXEC sp_CapNhatDoanPhi 2, '2023-2024', 50000
GO

-- 9. SP kết hợp tham số và điều kiện: Báo cáo tổng hợp hoạt động của đoàn viên
CREATE PROCEDURE sp_BaoCaoHoatDongDoanVien
    @MaDoanVien INT = NULL,
    @TuNgay DATE = NULL,
    @DenNgay DATE = NULL
AS
BEGIN
    SELECT dv.MaDoanVien, dv.HoTen, hd.MaHoatDong, hd.TenHoatDong, hd.NgayToChuc,
           tg.VaiTro, tg.DiemRenLuyen
    FROM DoanVien dv
    JOIN ThamGiaHoatDong tg ON dv.MaDoanVien = tg.MaDoanVien
    JOIN HoatDong hd ON tg.MaHoatDong = hd.MaHoatDong
    WHERE (@MaDoanVien IS NULL OR dv.MaDoanVien = @MaDoanVien)
    AND (@TuNgay IS NULL OR hd.NgayToChuc >= @TuNgay)
    AND (@DenNgay IS NULL OR hd.NgayToChuc <= @DenNgay)
    ORDER BY hd.NgayToChuc DESC
END
GO

EXEC sp_BaoCaoHoatDongDoanVien -- Không tham số
GO
EXEC sp_BaoCaoHoatDongDoanVien 1 -- Chỉ lọc theo MaDoanVien
GO
EXEC sp_BaoCaoHoatDongDoanVien NULL, '2023-01-01', '2023-12-31' -- Lọc theo khoảng thời gian
GO

-- 10. SP phức tạp: Cập nhật điểm rèn luyện và trạng thái đoàn viên
CREATE PROCEDURE sp_CapNhatDiemVaTrangThai
    @MaDoanVien INT,
    @MaHoatDong INT,
    @DiemRenLuyen INT,
    @KetQuaCapNhat NVARCHAR(100) OUTPUT
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION
        
        -- Cập nhật điểm rèn luyện
        UPDATE ThamGiaHoatDong
        SET DiemRenLuyen = @DiemRenLuyen
        WHERE MaDoanVien = @MaDoanVien AND MaHoatDong = @MaHoatDong
        
        -- Kiểm tra điểm trung bình
        DECLARE @DiemTrungBinh FLOAT
        SELECT @DiemTrungBinh = AVG(CAST(DiemRenLuyen AS FLOAT))
        FROM ThamGiaHoatDong
        WHERE MaDoanVien = @MaDoanVien AND DiemRenLuyen IS NOT NULL
        
        -- Cập nhật trạng thái đoàn viên dựa trên điểm trung bình
        IF @DiemTrungBinh < 50
        BEGIN
            UPDATE DoanVien
            SET TrangThai = N'Không hoạt động'
            WHERE MaDoanVien = @MaDoanVien
            
            SET @KetQuaCapNhat = N'Đã cập nhật điểm và chuyển trạng thái thành Không hoạt động'
        END
        ELSE
        BEGIN
            UPDATE DoanVien
            SET TrangThai = N'Hoạt động'
            WHERE MaDoanVien = @MaDoanVien
            
            SET @KetQuaCapNhat = N'Đã cập nhật điểm và chuyển trạng thái thành Hoạt động'
        END
        
        COMMIT TRANSACTION
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION
        SET @KetQuaCapNhat = N'Lỗi: ' + ERROR_MESSAGE()
    END CATCH
END
GO

DECLARE @KetQua NVARCHAR(100)
EXEC sp_CapNhatDiemVaTrangThai 3, 203, 45, @KetQua OUTPUT
SELECT @KetQua AS KetQuaCapNhat
GO



----**Tạo 10 function (trả về kiểu vô hướng, bảng, biến bảng)
-- 1. Function vô hướng: Tính số năm tham gia đoàn của đoàn viên
CREATE FUNCTION fn_TinhThoiGianThamGiaDoan (@MaDoanVien INT)
RETURNS INT
AS
BEGIN
    DECLARE @SoNam INT
    
    SELECT @SoNam = DATEDIFF(YEAR, NgayVaoDoan, GETDATE())
    FROM DoanVien
    WHERE MaDoanVien = @MaDoanVien
    
    RETURN ISNULL(@SoNam, 0)
END
GO

SELECT dbo.fn_TinhThoiGianThamGiaDoan(1) AS SoNamThamGiaDoan
GO

-- 2. Function vô hướng: Tính tổng số đoàn phí đã đóng của đoàn viên
CREATE FUNCTION fn_TinhTongDoanPhi (@MaDoanVien INT)
RETURNS DECIMAL(10,2)
AS
BEGIN
    DECLARE @TongDoanPhi DECIMAL(10,2)
    
    SELECT @TongDoanPhi = ISNULL(SUM(SoTien), 0)
    FROM DongGopDoanPhi
    WHERE MaDoanVien = @MaDoanVien AND TrangThai = N'Đã đóng'
    
    RETURN @TongDoanPhi
END
GO

SELECT dbo.fn_TinhTongDoanPhi(1) AS TongDoanPhiDaDong
GO

-- 3. Function vô hướng: Tính điểm rèn luyện trung bình của đoàn viên
CREATE FUNCTION fn_TinhDiemTrungBinh (@MaDoanVien INT)
RETURNS FLOAT
AS
BEGIN
    DECLARE @DiemTrungBinh FLOAT
    
    SELECT @DiemTrungBinh = AVG(CAST(DiemRenLuyen AS FLOAT))
    FROM ThamGiaHoatDong
    WHERE MaDoanVien = @MaDoanVien AND DiemRenLuyen IS NOT NULL
    
    RETURN ISNULL(@DiemTrungBinh, 0)
END
GO

SELECT dbo.fn_TinhDiemTrungBinh(1) AS DiemRenLuyenTrungBinh
GO

-- 4. Function vô hướng: Đếm số hoạt động đoàn viên đã tham gia
CREATE FUNCTION fn_DemSoHoatDong (@MaDoanVien INT)
RETURNS INT
AS
BEGIN
    DECLARE @SoHoatDong INT
    
    SELECT @SoHoatDong = COUNT(*)
    FROM ThamGiaHoatDong
    WHERE MaDoanVien = @MaDoanVien
    
    RETURN ISNULL(@SoHoatDong, 0)
END
GO

SELECT dbo.fn_DemSoHoatDong(1) AS SoHoatDongThamGia
GO

-- 5. Function trả về bảng: Danh sách hoạt động đoàn viên đã tham gia
CREATE OR ALTER FUNCTION fn_DanhSachHoatDong (@MaDoanVien INT)
RETURNS TABLE
AS
RETURN
(
    SELECT TOP 100 PERCENT hd.MaHoatDong, hd.TenHoatDong, hd.NgayToChuc, hd.DiaDiem, 
           tg.VaiTro, tg.DiemRenLuyen
    FROM HoatDong hd
    JOIN ThamGiaHoatDong tg ON hd.MaHoatDong = tg.MaHoatDong
    WHERE tg.MaDoanVien = @MaDoanVien
    ORDER BY hd.NgayToChuc DESC
)
GO

SELECT * FROM fn_DanhSachHoatDong(1)
GO

-- 6. Function trả về bảng: Lịch sử đóng đoàn phí của đoàn viên
CREATE OR ALTER FUNCTION fn_LichSuDongDoanPhi (@MaDoanVien INT)
RETURNS TABLE
AS
RETURN
(
    SELECT TOP 100 PERCENT MaGiaoDich, SoTien, NgayDong, NamHoc, TrangThai
    FROM DongGopDoanPhi
    WHERE MaDoanVien = @MaDoanVien
    ORDER BY NgayDong DESC
)
GO

SELECT * FROM fn_LichSuDongDoanPhi(1)
GO

-- 7. Function trả về bảng: Danh sách khen thưởng và kỷ luật của đoàn viên
CREATE OR ALTER FUNCTION fn_DanhSachKhenThuongKyLuat (@MaDoanVien INT)
RETURNS TABLE
AS
RETURN
(
    SELECT TOP 100 PERCENT MaKhenThuong, Loai, MoTa, NgayQuyetDinh, CapQuyetDinh
    FROM KhenThuongKyLuat
    WHERE MaDoanVien = @MaDoanVien
    ORDER BY NgayQuyetDinh DESC
)
GO

SELECT * FROM fn_DanhSachKhenThuongKyLuat(1)
GO

-- 8. Function trả về bảng nhiều tham số: Tìm kiếm hoạt động theo thời gian và địa điểm
CREATE FUNCTION fn_TimKiemHoatDong 
(
    @TuNgay DATE = NULL,
    @DenNgay DATE = NULL,
    @DiaDiem NVARCHAR(255) = NULL
)
RETURNS TABLE
AS
RETURN
(
    SELECT MaHoatDong, TenHoatDong, NgayToChuc, DiaDiem, MoTa, MaChiDoan
    FROM HoatDong
    WHERE (@TuNgay IS NULL OR NgayToChuc >= @TuNgay)
    AND (@DenNgay IS NULL OR NgayToChuc <= @DenNgay)
    AND (@DiaDiem IS NULL OR DiaDiem LIKE N'%' + @DiaDiem + N'%')
)
GO

SELECT * FROM fn_TimKiemHoatDong('2023-01-01', '2023-12-31', NULL)
GO

-- 9. Function trả về biến bảng: Báo cáo tổng hợp thông tin đoàn viên
CREATE FUNCTION fn_BaoCaoTongHopDoanVien (@MaDoanVien INT = NULL)
RETURNS @KetQua TABLE
(
    MaDoanVien INT,
    HoTen NVARCHAR(100),
    NgayVaoDoan DATE,
    ThoiGianThamGia INT,
    SoHoatDongThamGia INT,
    DiemTrungBinh FLOAT,
    TongDoanPhi DECIMAL(10,2),
    SoLanKhenThuong INT,
    SoLanKyLuat INT
)
AS
BEGIN
    INSERT INTO @KetQua
    SELECT 
        dv.MaDoanVien,
        dv.HoTen,
        dv.NgayVaoDoan,
        DATEDIFF(YEAR, dv.NgayVaoDoan, GETDATE()) AS ThoiGianThamGia,
        COUNT(DISTINCT tg.MaHoatDong) AS SoHoatDongThamGia,
        AVG(CAST(tg.DiemRenLuyen AS FLOAT)) AS DiemTrungBinh,
        ISNULL(SUM(dp.SoTien), 0) AS TongDoanPhi,
        SUM(CASE WHEN kt.Loai = N'Khen thưởng' THEN 1 ELSE 0 END) AS SoLanKhenThuong,
        SUM(CASE WHEN kt.Loai = N'Kỷ luật' THEN 1 ELSE 0 END) AS SoLanKyLuat
    FROM DoanVien dv
    LEFT JOIN ThamGiaHoatDong tg ON dv.MaDoanVien = tg.MaDoanVien
    LEFT JOIN DongGopDoanPhi dp ON dv.MaDoanVien = dp.MaDoanVien
    LEFT JOIN KhenThuongKyLuat kt ON dv.MaDoanVien = kt.MaDoanVien
    WHERE (@MaDoanVien IS NULL OR dv.MaDoanVien = @MaDoanVien)
    GROUP BY dv.MaDoanVien, dv.HoTen, dv.NgayVaoDoan
    
    RETURN
END
GO

SELECT * FROM fn_BaoCaoTongHopDoanVien(NULL) -- Tất cả đoàn viên
SELECT * FROM fn_BaoCaoTongHopDoanVien(1) -- Một đoàn viên cụ thể
GO

-- 10. Function trả về biến bảng: Phân tích hoạt động đoàn viên theo vai trò
CREATE FUNCTION fn_PhanTichVaiTroDoanVien()
RETURNS @KetQua TABLE
(
    MaDoanVien INT,
    HoTen NVARCHAR(100),
    SoLanLamThanhVien INT,
    SoLanLamBanToChuc INT,
    SoLanLamTinhNguyenVien INT,
    TongSoHoatDong INT,
    PhanTramBanToChuc DECIMAL(5,2)
)
AS
BEGIN
    INSERT INTO @KetQua
    SELECT 
        dv.MaDoanVien,
        dv.HoTen,
        COUNT(CASE WHEN tg.VaiTro = N'Thành viên' THEN 1 END) AS SoLanLamThanhVien,
        COUNT(CASE WHEN tg.VaiTro = N'Ban tổ chức' THEN 1 END) AS SoLanLamBanToChuc,
        COUNT(CASE WHEN tg.VaiTro = N'Tình nguyện viên' THEN 1 END) AS SoLanLamTinhNguyenVien,
        COUNT(*) AS TongSoHoatDong,
        CASE 
            WHEN COUNT(*) > 0 THEN 
                CAST(COUNT(CASE WHEN tg.VaiTro = N'Ban tổ chức' THEN 1 END) AS DECIMAL(5,2)) / COUNT(*) * 100
            ELSE 0 
        END AS PhanTramBanToChuc
    FROM DoanVien dv
    LEFT JOIN ThamGiaHoatDong tg ON dv.MaDoanVien = tg.MaDoanVien
    GROUP BY dv.MaDoanVien, dv.HoTen
    
    RETURN
END
GO

SELECT * FROM fn_PhanTichVaiTroDoanVien()
GO


----**Tạo 7- 10 trigger để kiểm soát dữ liệu
-- 1. Trigger cập nhật số lượng đoàn viên trong Chi đoàn khi thêm đoàn viên mới
CREATE TRIGGER trg_CapNhatSoLuongDoanVien
ON DoanVien
AFTER INSERT
AS
BEGIN
    UPDATE ChiDoan
    SET SoLuongDoanVien = SoLuongDoanVien + 1
    WHERE MaChiDoan IN (SELECT MaChiDoan FROM ChiDoan WHERE BiThuDoanVienID IN (SELECT MaDoanVien FROM inserted));
END;
GO

INSERT INTO DoanVien (MaDoanVien, HoTen, NgaySinh, GioiTinh, DiaChi, SoDienThoai, Email, NgayVaoDoan, TrangThai)
VALUES (4, N'Phạm Văn Đức', '2000-07-20', N'Nam', N'Hà Nội', '0987654321', 'duc@gmail.com', '2020-01-01', N'Hoạt động');
SELECT * FROM ChiDoan WHERE BiThuDoanVienID = 1;

-- 2. Trigger kiểm tra tuổi đoàn viên khi thêm mới
CREATE OR ALTER TRIGGER trg_KiemTraTuoi
ON DoanVien
AFTER INSERT
AS
BEGIN
    IF EXISTS (SELECT 1 FROM inserted WHERE DATEDIFF(YEAR, NgaySinh, GETDATE()) < 16)
    BEGIN
        RAISERROR(N'Đoàn viên phải từ 16 tuổi trở lên', 16, 1);
        ROLLBACK TRANSACTION;
    END
END;
GO

INSERT INTO DoanVien (MaDoanVien, HoTen, NgaySinh, GioiTinh, DiaChi, SoDienThoai, Email, NgayVaoDoan, TrangThai)
VALUES (10, N'Trần Văn Em', '2000-01-01', N'Nam', N'Hà Nội', '0912345678', 'em@gmail.com', '2023-01-01', N'Hoạt động');


-- 3. Trigger ngăn xóa hoạt động đã diễn ra
CREATE TRIGGER trg_KhongXoaHoatDongCu
ON HoatDong
INSTEAD OF DELETE
AS
BEGIN
    IF EXISTS (SELECT 1 FROM deleted WHERE NgayToChuc < GETDATE())
    BEGIN
        RAISERROR(N'Không thể xóa hoạt động đã diễn ra', 16, 1);
    END
    ELSE
    BEGIN
        DELETE FROM HoatDong WHERE MaHoatDong IN (SELECT MaHoatDong FROM deleted);
    END
END;
GO

DELETE FROM HoatDong WHERE MaHoatDong = 201;

-- 4. Trigger cập nhật trạng thái đoàn viên khi đóng đoàn phí (giữ nguyên nhưng sửa câu kiểm tra)
CREATE OR ALTER TRIGGER trg_CapNhatTrangThai
ON DongGopDoanPhi
AFTER INSERT
AS
BEGIN
    UPDATE DoanVien
    SET TrangThai = N'Hoạt động'
    FROM DoanVien
    JOIN inserted ON DoanVien.MaDoanVien = inserted.MaDoanVien
    WHERE inserted.TrangThai = N'Đã đóng';
END;
GO

INSERT INTO DongGopDoanPhi (MaGiaoDich, MaDoanVien, SoTien, NgayDong, NamHoc, TrangThai)
VALUES (501, 3, 50000, '2023-03-15', '2022-2023', N'Đã đóng');
SELECT * FROM DoanVien WHERE MaDoanVien = 3;

-- 5. Trigger kiểm tra số điện thoại
CREATE TRIGGER trg_KiemTraSDT
ON DoanVien
AFTER INSERT, UPDATE
AS
BEGIN
    IF EXISTS (SELECT 1 FROM inserted WHERE SoDienThoai IS NOT NULL AND LEN(SoDienThoai) NOT IN (10, 11))
    BEGIN
        RAISERROR(N'Số điện thoại phải có 10 hoặc 11 số', 16, 1);
        ROLLBACK TRANSACTION;
    END
END;
GO

UPDATE DoanVien SET SoDienThoai = '0373617025' WHERE MaDoanVien = 1;

-- 6. Trigger kiểm tra tham gia hoạt động
CREATE TRIGGER trg_KiemTraThamGia
ON ThamGiaHoatDong
INSTEAD OF INSERT
AS
BEGIN
    IF EXISTS (
        SELECT 1 
        FROM inserted i
        JOIN HoatDong h ON i.MaHoatDong = h.MaHoatDong
        WHERE h.NgayToChuc > GETDATE() AND i.DiemRenLuyen IS NOT NULL
    )
    BEGIN
        RAISERROR(N'Không thể nhập điểm cho hoạt động chưa diễn ra', 16, 1);
    END
    ELSE
    BEGIN
        INSERT INTO ThamGiaHoatDong (MaDoanVien, MaHoatDong, VaiTro, DiemRenLuyen)
        SELECT MaDoanVien, MaHoatDong, VaiTro, DiemRenLuyen FROM inserted;
    END
END;
GO

INSERT INTO HoatDong (MaHoatDong, TenHoatDong, NgayToChuc, DiaDiem, MoTa, MaChiDoan)
VALUES (204, N'Hoạt động tương lai', '2025-01-01', N'Hà Nội', N'Hoạt động tương lai', 101);

INSERT INTO ThamGiaHoatDong (MaDoanVien, MaHoatDong, VaiTro, DiemRenLuyen)
VALUES (1, 204, N'Thành viên', 90);

-- 7. Trigger ngăn xóa bí thư chi đoàn
CREATE TRIGGER trg_KhongXoaBiThu
ON DoanVien
INSTEAD OF DELETE
AS
BEGIN
    IF EXISTS (SELECT 1 FROM deleted d JOIN ChiDoan c ON d.MaDoanVien = c.BiThuDoanVienID)
    BEGIN
        RAISERROR(N'Không thể xóa đoàn viên là bí thư', 16, 1);
    END
    ELSE
    BEGIN
        DELETE FROM DoanVien WHERE MaDoanVien IN (SELECT MaDoanVien FROM deleted);
    END
END;
GO

DELETE FROM DoanVien WHERE MaDoanVien = 1;