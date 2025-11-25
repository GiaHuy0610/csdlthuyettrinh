-- 1. Tạo Database
CREATE DATABASE quanlysach;
GO
USE quanlysach;
GO

-- 2. Tạo bảng Sách (Book)
CREATE TABLE Sach (
    MaSach VARCHAR(10) PRIMARY KEY,
    TenSach NVARCHAR(100) NOT NULL,
    TacGia NVARCHAR(50),
    SoLuongTon INT DEFAULT 0
);

-- 3. Tạo bảng Độc giả (Reader)
CREATE TABLE DocGia (
    MaDG VARCHAR(10) PRIMARY KEY,
    TenDG NVARCHAR(50) NOT NULL,
    DiaChi NVARCHAR(100)
);

-- 4. Tạo bảng Thư viện viên (Librarian) - Người cho mượn sách
CREATE TABLE ThuVienVien (
    MaTVV VARCHAR(10) PRIMARY KEY,
    TenTVV NVARCHAR(50) NOT NULL
);

-- 5. Tạo bảng Phiếu mượn (Lưu thông tin mượn trả)
-- Để đơn giản, mỗi dòng là một cuốn sách được mượn
CREATE TABLE PhieuMuon (
    MaPhieu INT IDENTITY(1,1) PRIMARY KEY, -- Mã tự tăng
    MaDG VARCHAR(10) REFERENCES DocGia(MaDG),
    MaSach VARCHAR(10) REFERENCES Sach(MaSach),
    MaTVV VARCHAR(10) REFERENCES ThuVienVien(MaTVV),
    NgayMuon DATE DEFAULT GETDATE(),
    HanTra DATE,        -- Hạn phải trả
    NgayTra DATE,       -- Ngày thực tế trả (Nếu NULL là chưa trả)
    GhiChu NVARCHAR(100)
);
GO

-- === THÊM DỮ LIỆU MẪU ĐỂ TEST (Bước này quan trọng để chạy được các câu dưới) ===
INSERT INTO Sach VALUES ('S01', N'Nhà Giả Kim', N'Paulo Coelho', 10);
INSERT INTO Sach VALUES ('S02', N'Đắc Nhân Tâm', N'Dale Carnegie', 15);
INSERT INTO Sach VALUES ('S03', N'Harry Potter', N'J.K. Rowling', 5);

INSERT INTO DocGia VALUES ('DG01', N'Nguyễn Văn An', N'TP.HCM');
INSERT INTO DocGia VALUES ('DG02', N'Trần Thị Bích', N'Hà Nội');

INSERT INTO ThuVienVien VALUES ('TVV01', N'Cô Thu Thư');
INSERT INTO ThuVienVien VALUES ('TVV02', N'Thầy Quản Lý');

-- Dữ liệu mượn:
-- Phiếu 1: Mượn tháng 5/2024, chưa trả (Quá hạn giả định)
INSERT INTO PhieuMuon (MaDG, MaSach, MaTVV, NgayMuon, HanTra, NgayTra) 
VALUES ('DG01', 'S01', 'TVV01', '2024-05-01', '2024-05-15', NULL);

-- Phiếu 2: Mượn tháng 5/2024, đã trả
INSERT INTO PhieuMuon (MaDG, MaSach, MaTVV, NgayMuon, HanTra, NgayTra) 
VALUES ('DG02', 'S02', 'TVV01', '2024-05-10', '2024-05-20', '2024-05-18');

-- Phiếu 3: Mượn hiện tại (đang mượn)
INSERT INTO PhieuMuon (MaDG, MaSach, MaTVV, NgayMuon, HanTra, NgayTra) 
VALUES ('DG02', 'S03', 'TVV02', GETDATE(), DATEADD(day, 14, GETDATE()), NULL);
GO


SELECT 
    (SELECT COUNT(*) FROM Sach) AS TongSoSach,
    (SELECT COUNT(*) FROM DocGia) AS TongSoDocGia;

INSERT INTO Sach VALUES ('S04', N'Dế Mèn Phiêu Lưu Ký', N'Tô Hoài', 20);
INSERT INTO DocGia VALUES ('DG03', N'Lê Văn Cường', N'Đà Nẵng');
INSERT INTO ThuVienVien VALUES ('TVV03', N'Nguyễn Văn Mới');

SELECT DISTINCT DG.MaDG, DG.TenDG
FROM DocGia DG
JOIN PhieuMuon PM ON DG.MaDG = PM.MaDG
WHERE PM.NgayTra IS NULL;

SELECT DISTINCT S.MaSach, S.TenSach
FROM Sach S
JOIN PhieuMuon PM ON S.MaSach = PM.MaSach
WHERE PM.NgayTra IS NULL;

SELECT S.TenSach, PM.NgayMuon, PM.HanTra
FROM PhieuMuon PM
JOIN Sach S ON PM.MaSach = S.MaSach
WHERE PM.MaDG = 'DG01' -- Thay mã độc giả bạn muốn tìm vào đây
  AND PM.NgayTra IS NULL;

SELECT TOP 5 S.MaSach, S.TenSach, COUNT(PM.MaSach) AS SoLanMuon
FROM Sach S
JOIN PhieuMuon PM ON S.MaSach = PM.MaSach
GROUP BY S.MaSach, S.TenSach
ORDER BY SoLanMuon DESC;

SELECT *
FROM PhieuMuon
WHERE MaTVV = 'TVV01'; -- Thay mã TVV vào đây

SELECT *
FROM PhieuMuon
WHERE MaTVV = 'TVV01'
  AND MONTH(NgayMuon) = 5 
  AND YEAR(NgayMuon) = 2024;

  SELECT DISTINCT S.TenSach, PM.NgayMuon
FROM Sach S
JOIN PhieuMuon PM ON S.MaSach = PM.MaSach
WHERE MONTH(PM.NgayMuon) = 5 
  AND YEAR(PM.NgayMuon) = 2024;

SELECT DISTINCT DG.TenDG, PM.HanTra
FROM DocGia DG
JOIN PhieuMuon PM ON DG.MaDG = PM.MaDG
WHERE PM.NgayTra IS NULL 
  AND GETDATE() <= PM.HanTra;

SELECT DISTINCT DG.TenDG, PM.HanTra
FROM DocGia DG
JOIN PhieuMuon PM ON DG.MaDG = PM.MaDG
WHERE PM.NgayTra IS NULL 
  AND GETDATE() > PM.HanTra;