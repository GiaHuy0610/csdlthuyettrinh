-- 1. Tạo Database
CREATE DATABASE quanlysach
GO
USE quanlysach
GO

-- 2. Bảng Sách (Bỏ cột Thể Loại)
CREATE TABLE Sach
(
    MaSach      nvarchar(10) PRIMARY KEY,
    TenSach     nvarchar(100),
    TacGia      nvarchar(50),
    NamXuatBan  int
)
GO

-- 3. Bảng Thể Loại Sách (Bảng phụ 1 - Xử lý đa trị)
CREATE TABLE TheLoaiSach
(
    MaSach      nvarchar(10),
    TheLoai     nvarchar(50),
    
    PRIMARY KEY (MaSach, TheLoai),
    FOREIGN KEY (MaSach) REFERENCES Sach(MaSach)
)
GO

-- 4. Bảng Độc Giả (Bỏ cột SDT)
CREATE TABLE DocGia
(
    MaDG        nvarchar(10) PRIMARY KEY,
    TenDG       nvarchar(50),
    DiaChi      nvarchar(100)
)
GO

-- 5. Bảng Điện Thoại Độc Giả (Bảng phụ 2 - Xử lý đa trị)
-- Một độc giả có thể có nhiều số điện thoại
CREATE TABLE DienThoaiDocGia
(
    MaDG        nvarchar(10),
    SDT         nvarchar(15),

    PRIMARY KEY (MaDG, SDT),
    FOREIGN KEY (MaDG) REFERENCES DocGia(MaDG)
)
GO

-- 6. Bảng Thư Viện Viên
CREATE TABLE ThuVienVien
(
    MaTVV       nvarchar(10) PRIMARY KEY,
    TenTVV      nvarchar(50)
)
GO

-- 7. Bảng Giao Dịch
CREATE TABLE GiaoDich
(
    MaGD            nvarchar(10) PRIMARY KEY,
    MaSach          nvarchar(10) REFERENCES Sach(MaSach),
    MaDG            nvarchar(10) REFERENCES DocGia(MaDG),
    MaTVV           nvarchar(10) REFERENCES ThuVienVien(MaTVV),
    NgayMuon        date,
    NgayTraDuKien   date,
    NgayTraThucTe   date -- Nếu NULL nghĩa là chưa trả
)
GO

-- 1. Thêm Sách
INSERT INTO Sach VALUES ('S01', N'Nhà Giả Kim',  N'Paulo Coelho',  2020)
INSERT INTO Sach VALUES ('S02', N'Đắc Nhân Tâm', N'Dale Carnegie', 2019)
INSERT INTO Sach VALUES ('S03', N'Harry Potter', N'J.K. Rowling',  2021)
GO

-- 2. Thêm Thể Loại (Đa trị)
INSERT INTO TheLoaiSach VALUES ('S01', N'Văn học')
INSERT INTO TheLoaiSach VALUES ('S01', N'Tiểu thuyết') -- S01 có 2 thể loại
INSERT INTO TheLoaiSach VALUES ('S02', N'Kỹ năng sống')
INSERT INTO TheLoaiSach VALUES ('S03', N'Viễn tưởng')
GO

-- 3. Thêm Độc giả
INSERT INTO DocGia VALUES ('DG01', N'Nguyễn Văn A', N'Hà Nội')
INSERT INTO DocGia VALUES ('DG02', N'Trần Thị B',   N'TP.HCM')
GO

-- 4. Thêm Số điện thoại (Đa trị)
INSERT INTO DienThoaiDocGia VALUES ('DG01', '0901234567')
INSERT INTO DienThoaiDocGia VALUES ('DG01', '0911112222') -- Ông A có 2 số
INSERT INTO DienThoaiDocGia VALUES ('DG02', '0909888777')
GO

-- 5. Thêm Thư viện viên
INSERT INTO ThuVienVien VALUES ('TVV01', N'Cô Thủ Thư A')
INSERT INTO ThuVienVien VALUES ('TVV02', N'Thầy Quản Lý B')
GO

-- 6. Thêm Giao dịch
-- GD01: Đã trả
INSERT INTO GiaoDich VALUES ('GD01', 'S01', 'DG01', 'TVV01', '2024-05-01', '2024-05-15', '2024-05-10')
-- GD02: Đang mượn
INSERT INTO GiaoDich VALUES ('GD02', 'S02', 'DG02', 'TVV01', '2024-05-20', '2024-05-27', NULL)
-- GD03: Quá hạn
INSERT INTO GiaoDich VALUES ('GD03', 'S03', 'DG01', 'TVV02', '2024-05-01', '2024-05-15', NULL)
GO

-- Câu 1: Liệt kê tổng số sách (book) và tổng số độc giả (reader) có trong thư viện
SELECT
    (SELECT COUNT(*) FROM Sach)   AS TongSoSach,
    (SELECT COUNT(*) FROM DocGia) AS TongSoDocGia

-- Câu 2: Thêm 1 cuốn sách mới, bạn đọc mới và một thư viện viên mới vào CSDL
-- A. Thêm Sách mới
INSERT INTO Sach VALUES ('S05', N'Dế Mèn Phiêu Lưu Ký', N'Tô Hoài', 2018)
-- Thêm thể loại cho sách đó
INSERT INTO TheLoaiSach VALUES ('S05', N'Thiếu nhi')

-- B. Thêm Độc giả mới
INSERT INTO DocGia VALUES ('DG03', N'Lê Văn C', N'Đà Nẵng')
-- Thêm số điện thoại cho độc giả đó
INSERT INTO DienThoaiDocGia VALUES ('DG03', '0912345678')

-- C. Thêm Thư viện viên mới
INSERT INTO ThuVienVien VALUES ('TVV03', N'Nhân Viên Mới')

-- Câu 3: Liệt kê tất cả các bạn đọc đang được mượn sách
SELECT DISTINCT
    DG.MaDG,
    DG.TenDG
FROM
    DocGia AS DG
    INNER JOIN GiaoDich AS GD ON DG.MaDG = GD.MaDG
WHERE
    GD.NgayTraThucTe IS NULL

-- Câu 4: Liệt kê tất cả các sách ĐANG được mượn
SELECT DISTINCT
    S.MaSach,
    S.TenSach
FROM
    Sach AS S
    INNER JOIN GiaoDich AS GD ON S.MaSach = GD.MaSach
WHERE
    GD.NgayTraThucTe IS NULL

-- Câu 5: Liệt kê tất cả các sách đang được mượn của một mã độc giả bất kỳ
SELECT DISTINCT
    S.MaSach,
    S.TenSach
FROM
    Sach AS S
    INNER JOIN GiaoDich AS GD ON S.MaSach = GD.MaSach
WHERE
    GD.NgayTraThucTe IS NULL

-- Câu 6: Cho biết 5 cuốn sách được mượn nhiều nhất
SELECT TOP 5
    S.TenSach,
    COUNT(GD.MaSach) AS SoLanMuon
FROM
    Sach AS S
    INNER JOIN GiaoDich AS GD ON S.MaSach = GD.MaSach
GROUP BY
    S.TenSach
ORDER BY
    SoLanMuon DESC

-- Câu 7: Cho biết các phiếu xử lý mượn/trả của một thư viện viên bất kỳ
SELECT *
FROM
    GiaoDich
WHERE
    MaTVV = 'TVV01'

-- Câu 8: Cho biết các phiếu xử lý mượn/trả của một thư viện viên bất kỳ trong 5/2024
SELECT *
FROM
    GiaoDich
WHERE
    MaTVV = 'TVV01'
    AND NgayMuon >= '2024-05-01'
    AND NgayMuon <= '2024-05-31'    

-- Câu 9: Liệt kê tất cả các sách được mược trong thời gian tháng 5/2024
SELECT DISTINCT
    S.TenSach,
    GD.NgayMuon
FROM
    Sach AS S
    INNER JOIN GiaoDich AS GD ON S.MaSach = GD.MaSach
WHERE
    GD.NgayMuon >= '2024-05-01'
    AND GD.NgayMuon <= '2024-05-31'

-- Câu 10: Tìm tất cả các độc giả đang mượn sách (trong hạn cho phép).
SELECT DISTINCT
    DG.TenDG,
    GD.NgayTraDuKien
FROM
    DocGia AS DG
    INNER JOIN GiaoDich AS GD ON DG.MaDG = GD.MaDG
WHERE
    GD.NgayTraThucTe IS NULL
    AND GD.NgayTraDuKien >= '2024-05-25'

-- Câu 11: Tìm độc giả mượn QUÁ HẠN (Chưa trả)
SELECT DISTINCT
    DG.TenDG,
    GD.NgayTraDuKien
FROM
    DocGia AS DG
    INNER JOIN GiaoDich AS GD ON DG.MaDG = GD.MaDG
WHERE
    GD.NgayTraThucTe IS NULL
    AND GD.NgayTraDuKien < '2024-05-25'