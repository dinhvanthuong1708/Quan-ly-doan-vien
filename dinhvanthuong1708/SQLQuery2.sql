--Truy vấn cơ bản
USE QLDoanVien;


-- INNER JOIN --
-- 1. Hiển thị danh sách đoàn viên và tên chi đoàn họ thuộc về
SELECT DV.MaDoanVien, DV.HoTen, CD.TenChiDoan
FROM DoanVien DV
INNER JOIN ChiDoan CD ON DV.MaDoanVien = CD.BiThuDoanVienID;


-- 2. Hiển thị danh sách hoạt động và số lượng đoàn viên tham gia
SELECT HD.MaHoatDong, HD.TenHoatDong, COUNT(TG.MaDoanVien) AS SoLuongThamGia
FROM HoatDong HD
INNER JOIN ThamGiaHoatDong TG ON HD.MaHoatDong = TG.MaHoatDong
GROUP BY HD.MaHoatDong, HD.TenHoatDong
-- GROUP BY --
-- 3. Thống kê số lượng đoàn viên theo giới tính
SELECT GioiTinh, COUNT(*) AS SoLuongDoanVien
FROM DoanVien
GROUP BY GioiTinh;

-- 4. Thống kê tổng số tiền đóng đoàn phí theo năm học
SELECT NamHoc, SUM(SoTien) AS TongSoTien
FROM DongGopDoanPhi
GROUP BY NamHoc;

-- HAVING --
-- 5. Hiển thị các chi đoàn có số lượng đoàn viên lớn hơn 20
SELECT MaChiDoan, TenChiDoan, SoLuongDoanVien
FROM ChiDoan
GROUP BY MaChiDoan, TenChiDoan, SoLuongDoanVien
HAVING SoLuongDoanVien > 20;

-- 6. Hiển thị đoàn viên tham gia nhiều hơn 1 hoạt động
SELECT DV.MaDoanVien, DV.HoTen, COUNT(TG.MaHoatDong) AS SoHoatDongThamGia
FROM DoanVien DV
INNER JOIN ThamGiaHoatDong TG ON DV.MaDoanVien = TG.MaDoanVien
GROUP BY DV.MaDoanVien, DV.HoTen
HAVING COUNT(TG.MaHoatDong) > 1;

-- SUBQUERY --
-- 7. Hiển thị đoàn viên có điểm rèn luyện cao nhất
SELECT DV.MaDoanVien, DV.HoTen, TG.DiemRenLuyen
FROM DoanVien DV
INNER JOIN ThamGiaHoatDong TG ON DV.MaDoanVien = TG.MaDoanVien
WHERE TG.DiemRenLuyen = (
    SELECT MAX(DiemRenLuyen)
    FROM ThamGiaHoatDong
);

-- 8. Hiển thị danh sách đoàn viên không tham gia bất kỳ hoạt động nào
SELECT MaDoanVien, HoTen, NgaySinh
FROM DoanVien
WHERE MaDoanVien NOT IN (
    SELECT DISTINCT MaDoanVien
    FROM ThamGiaHoatDong
);
