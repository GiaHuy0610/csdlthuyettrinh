-- 1. Bảng Sách
CREATE TABLE Sach
(
    MaSach      nvarchar(10) PRIMARY KEY,
    TenSach     nvarchar(100),
    TacGia      nvarchar(50),
    NamXuatBan  int,
    TheLoai     nvarchar(50)
)
GO

-- 2. Bảng Độc Giả
CREATE TABLE DocGia
(
    MaDG        nvarchar(10) PRIMARY KEY,
    TenDG       nvarchar(50),
    DiaChi      nvarchar(100),
    SDT         nvarchar(15)
)
GO

-- 3. Bảng Thư Viện Viên
CREATE TABLE ThuVienVien
(
    MaTVV       nvarchar(10) PRIMARY KEY,
    TenTVV      nvarchar(50)
)
GO

-- 4. Bảng Giao Dịch
-- Khóa ngoại được khai báo ngay cạnh cột (theo ví dụ file [cite: 97-98])
CREATE TABLE GiaoDich
(
    MaGD            nvarchar(10) PRIMARY KEY,
    MaSach          nvarchar(10) REFERENCES Sach(MaSach),
    MaDG            nvarchar(10) REFERENCES DocGia(MaDG),
    MaTVV           nvarchar(10) REFERENCES ThuVienVien(MaTVV),
    NgayMuon        date,
    NgayTraDuKien   date,
    NgayTraThucTe   date
)
GO

-- 1. Thêm dữ liệu Bảng Sách
INSERT INTO Sach VALUES ('S01', N'Nhà Giả Kim',  N'Paulo Coelho',  2020, N'Văn học')
INSERT INTO Sach VALUES ('S02', N'Đắc Nhân Tâm', N'Dale Carnegie', 2019, N'Kỹ năng')
INSERT INTO Sach VALUES ('S03', N'Harry Potter', N'J.K. Rowling',  2021, N'Viễn tưởng')
GO

-- 2. Thêm dữ liệu Bảng Độc giả
INSERT INTO DocGia VALUES ('DG01', N'Nguyễn Văn A', N'Hà Nội', '0901234567')
INSERT INTO DocGia VALUES ('DG02', N'Trần Thị B',   N'TP.HCM', '0909888777')
GO

-- 3. Thêm dữ liệu Bảng Thư viện viên
INSERT INTO ThuVienVien VALUES ('TVV01', N'Cô Thủ Thư A')
INSERT INTO ThuVienVien VALUES ('TVV02', N'Thầy Quản Lý B')
GO

-- 4. Thêm dữ liệu Bảng Giao dịch
-- GD01: Đã trả (Có ngày trả thực tế)
INSERT INTO GiaoDich VALUES ('GD01', 'S01', 'DG01', 'TVV01', '2024-05-01', '2024-05-15', '2024-05-10')

-- GD02: Đang mượn (NgayTraThucTe để NULL)
INSERT INTO GiaoDich VALUES ('GD02', 'S02', 'DG02', 'TVV01', '2024-05-20', '2024-05-27', NULL)

-- GD03: Quá hạn (Ngày dự kiến 15/05 nhưng nay vẫn chưa trả - NULL)
INSERT INTO GiaoDich VALUES ('GD03', 'S03', 'DG01', 'TVV02', '2024-05-01', '2024-05-15', NULL)
GO

-- Câu 1: Liệt kê tổng số sách (book) và tổng số độc giả (reader) có trong thư viện
SELECT
    (SELECT COUNT(*) FROM Sach)   AS TongSoSach,
    (SELECT COUNT(*) FROM DocGia) AS TongSoDocGia

-- Câu 2: Thêm 1 cuốn sách mới, bạn đọc mới và một thư viện viên mới vào csdl
INSERT INTO Sach
VALUES ('S05', N'Dế Mèn Phiêu Lưu Ký', N'Tô Hoài', 2018, N'Thiếu nhi')

INSERT INTO DocGia
VALUES ('DG03', N'Lê Văn C', N'Đà Nẵng', '0912345678')

INSERT INTO ThuVienVien
VALUES ('TVV03', N'Nhân Viên Mới')

-- Câu 3: Liệt kê tất cả các bạn đọc đang được mượn sách
SELECT DISTINCT
    DG.MaDG,
    DG.TenDG
FROM
    DocGia AS DG
    INNER JOIN GiaoDich AS GD ON DG.MaDG = GD.MaDG
WHERE
    GD.NgayTraThucTe IS NULL

-- Câu 4: Liệt kê tất cả các sách đang được mượn.
SELECT DISTINCT
    S.MaSach,
    S.TenSach
FROM
    Sach AS S
    INNER JOIN GiaoDich AS GD ON S.MaSach = GD.MaSach
WHERE
    GD.NgayTraThucTe IS NULL

-- Câu 5: Liệt kê tất cả các sách đang được mượn của một mã độc giả bất kỳ
SELECT
    S.TenSach,
    GD.NgayMuon,
    GD.NgayTraDuKien
FROM
    GiaoDich AS GD
    INNER JOIN Sach AS S ON GD.MaSach = S.MaSach
WHERE
    GD.MaDG = 'DG01'
    AND GD.NgayTraThucTe IS NULL

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

-- Câu 8: Cho biết các phiếu xử lý mượn/trả của một thư viện viên bất kỳ trong tháng
5/2024
SELECT *
FROM
    GiaoDich
WHERE
    MaTVV = 'TVV01'
    AND NgayMuon >= '2024-05-01'
    AND NgayMuon <= '2024-05-31'

-- Câu 9: Liệt kê sách được mượn trong tháng 5/2024
SELECT DISTINCT
    S.TenSach,
    GD.NgayMuon
FROM
    Sach AS S
    INNER JOIN GiaoDich AS GD ON S.MaSach = GD.MaSach
WHERE
    GD.NgayMuon >= '2024-05-01'
    AND GD.NgayMuon <= '2024-05-31'

-- Câu 10: Tìm độc giả đang mượn sách TRONG HẠN cho phép
SELECT DISTINCT
    DG.TenDG,
    GD.NgayTraDuKien
FROM
    DocGia AS DG
    INNER JOIN GiaoDich AS GD ON DG.MaDG = GD.MaDG
WHERE
    GD.NgayTraThucTe IS NULL
    AND GD.NgayTraDuKien >= '2024-05-25' -- Giả sử đây là ngày hiện tại

-- Câu 11: Tìm độc giả chưa trả sách khi TỚI HẠN TRẢ (Quá hạn)
SELECT DISTINCT
    DG.TenDG,
    GD.NgayTraDuKien
FROM
    DocGia AS DG
    INNER JOIN GiaoDich AS GD ON DG.MaDG = GD.MaDG
WHERE
    GD.NgayTraThucTe IS NULL
    AND GD.NgayTraDuKien < '2024-05-25' -- Giả sử đây là ngày hiện tại