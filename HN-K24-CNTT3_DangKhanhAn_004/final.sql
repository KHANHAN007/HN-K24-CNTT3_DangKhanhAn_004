DROP DATABASE IF EXISTS final;
CREATE DATABASE final;
USE final;

-- Phần 1:
CREATE TABLE Readers (
    reader_id INT PRIMARY KEY,
    full_name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    phone_number VARCHAR(15),
    created_at DATE
);

CREATE TABLE Membership_Details (
    card_id VARCHAR(20) PRIMARY KEY,
    reader_id INT,
    membership_level ENUM('Standard', 'VIP') NOT NULL,
    expiry_date DATE,
    citizen_id VARCHAR(20) UNIQUE,
    FOREIGN KEY (reader_id) REFERENCES Readers(reader_id)
);

CREATE TABLE Categories (
    category_id INT PRIMARY KEY,
    category_name VARCHAR(100) NOT NULL,
    description TEXT
);

CREATE TABLE Books (
    book_id INT PRIMARY KEY,
    title VARCHAR(200) NOT NULL,
    author VARCHAR(100) NOT NULL,
    category_id INT,
    price DECIMAL(10, 2) CHECK (price > 0),
    stock_quantity INT CHECK (stock_quantity >= 0),
    FOREIGN KEY (category_id) REFERENCES Categories(category_id)
);

CREATE TABLE Loan_Records (
    loan_id INT PRIMARY KEY,
    reader_id INT,
    book_id INT,
    borrow_date DATE NOT NULL,
    due_date DATE NOT NULL,
    return_date DATE DEFAULT NULL,
    FOREIGN KEY (reader_id) REFERENCES Readers(reader_id),
    FOREIGN KEY (book_id) REFERENCES Books(book_id),
    CHECK (due_date > borrow_date)
);

-- Thêm dữ liệu
INSERT INTO Readers (reader_id, full_name, email, phone_number, created_at) 
	VALUES 	(1, 'Nguyen Van A', 'anv@gmail.com', '901234567', '2022-01-15'),
			(2, 'Tran Thi B', 'btt@gmail.com', '912345678', '2022-05-20'),
			(3, 'Le Van C', 'cle@yahoo.com', '922334455', '2023-02-10'),
			(4, 'Pham Minh D', 'dpham@hotmail.com', '933445566', '2023-11-05'),
			(5, 'Hoang Anh E', 'ehoang@gmail.com', '944556677', '2024-01-12');
            
INSERT INTO Membership_Details (card_id, reader_id, membership_level, expiry_date, citizen_id) 
	VALUES 	('CARD-001', 1, 'Standard', '2025-01-15', '123456789'),
			('CARD-002', 2, 'VIP', '2025-05-20', '234567890'),
			('CARD-003', 3, 'Standard', '2024-02-10', '345678901'),
			('CARD-004', 4, 'VIP', '2025-11-05', '456789012'),
			('CARD-005', 5, 'Standard', '2026-01-12', '567890123');
            
INSERT INTO Categories (category_id, category_name, description) 
	VALUES 	(1, 'IT', 'Sách về công nghệ thông tin và lập trình'),
			(2, 'Kinh Te', 'Sách kinh doanh, tài chính, khởi nghiệp'),
			(3, 'Van Hoc', 'Tiểu thuyết, truyện ngắn, thơ'),
			(4, 'Ngoai Ngu', 'Sách học tiếng Anh, Nhật, Hàn'),
			(5, 'Lich Su', 'Sách nghiên cứu lịch sử, văn hóa');

INSERT INTO Books (book_id, title, author, category_id, price, stock_quantity) 
	VALUES 	(1, 'Clean Code', 'Robert C. Martin', 1, 450000, 10),
			(2, 'Dac Nhan Tam', 'Dale Carnegie', 2, 150000, 50),
			(3, 'Harry Potter 1', 'J.K. Rowling', 3, 250000, 5),
			(4, 'IELTS Reading', 'Cambridge', 4, 180000, 0),
			(5, 'Dai Viet Su Ky', 'Le Van Huu', 5, 300000, 20);

INSERT INTO Loan_Records (loan_id, reader_id, book_id, borrow_date, due_date, return_date) 
	VALUES 	(101, 1, 1, '2023-11-15', '2023-11-22', '2023-11-20'),
			(102, 2, 2, '2023-12-01', '2023-12-08', '2023-12-05'),
			(103, 1, 3, '2024-01-10', '2024-01-17', NULL),
			(104, 3, 4, '2023-05-20', '2023-05-27', NULL),
			(105, 4, 1, '2024-01-18', '2024-01-25', NULL);

-- Gia hạn thêm 7 ngày cho due_date (Ngày dự kiến trả) đối với tất cả các phiếu mượn sách thuộc danh mục 'Van Hoc' mà chưa được trả (return_date IS NULL).
UPDATE Loan_Records 
	SET due_date = DATE_ADD(due_date, INTERVAL 7 DAY) 
	WHERE book_id IN (SELECT book_id FROM Books WHERE category_id = (SELECT category_id FROM Categories WHERE category_name = 'Van Hoc')) 
		AND return_date IS NULL;

--  - Xóa các hồ sơ mượn trả (Loan_Records) đã hoàn tất trả sách (return_date KHÔNG NULL) và có ngày mượn trước tháng 10/2023.
-- DELETE FROM Loan_Records 
-- 	WHERE return_date IS NOT NULL 
-- 		AND borrow_date < '2023-10-01';

-- Phần 2: Truy vấn dữ liệu cơ bản
-- Lấy ra danh sách các cuốn sách (book_id, title, price) thuộc danh mục 'IT' và có giá bán lớn hơn 200.000 VNĐ.
SELECT b.book_id, b.title, b.price 
	FROM Books b 
	WHERE category_id = (SELECT c.category_id FROM Categories c WHERE c.category_name = 'IT') 
		AND b.price > 200000;
        
-- Lấy ra thông tin độc giả (reader_id, full_name, email) đã đăng ký tài khoản trong năm 2022 và có địa chỉ Email thuộc tên miền '@gmail.com'.
SELECT r.reader_id, r.full_name, r.email 
	FROM Readers r
	WHERE YEAR(r.created_at) = 2022 
    AND r.email LIKE '%@gmail.com';
    
-- Hiển thị danh sách 5 cuốn sách có giá trị cao nhất, sắp xếp theo thứ tự giảm dần.
-- Yêu cầu sử dụng LIMIT và OFFSET để bỏ qua 2 cuốn sách đắt nhất đầu tiên (lấy từ cuốn thứ 3 đến thứ 7).
SELECT b.book_id, b.title, b.author, (SELECT c.category_name FROM Categories c WHERE c.category_id = b.category_id) AS category_name, b.price, b.stock_quantity
	FROM Books b
	ORDER BY b.price DESC 
	LIMIT 5 OFFSET 2;
    
-- Phần 3: Truy vấn dữ liệu nâng cao
-- Viết truy vấn để hiển thị các thông tin gômg: Mã phiếu, Tên độc giả, Tên sách, Ngày mượn, Ngày trả. Chỉ hiển thị các đơn mượn chưa trả sách.
SELECT lr.loan_id, r.full_name, b.title, lr.borrow_date, lr.due_date 
	FROM Loan_Records lr 
		JOIN Readers r ON lr.reader_id = r.reader_id 
		JOIN Books b ON lr.book_id = b.book_id 
	WHERE lr.return_date IS NULL;
    
-- Tính tổng số lượng sách đang tồn kho (stock_quantity) của từng danh mục (category_name). Chỉ hiển thị những danh mục có tổng tồn kho lớn hơn 10.
SELECT c.category_name, SUM(b.stock_quantity) AS total_stock 
	FROM Categories c 
		JOIN Books b ON c.category_id = b.category_id 
	GROUP BY c.category_name 
	HAVING total_stock > 10;
    
-- Tìm ra thông tin độc giả (full_name) có hạng thẻ là 'VIP' nhưng chưa từng mượn cuốn sách nào có giá trị lớn hơn 300.000 VNĐ.
SELECT r.full_name 
	FROM Readers r 
		JOIN Membership_Details md ON r.reader_id = md.reader_id 
		LEFT JOIN Loan_Records lr ON r.reader_id = lr.reader_id AND lr.book_id IN (SELECT book_id FROM Books WHERE price > 300000) 
	WHERE md.membership_level = 'VIP' AND lr.loan_id IS NULL;
    
-- Phần 4: INDEX VÀ VIEW
-- Tạo một Composite Index đặt tên là idx_loan_dates trên bảng Loan_Records bao gồm hai cột: borrow_date và return_date để tăng tốc độ truy vấn lịch sử mượn.
CREATE INDEX idx_loan_dates ON Loan_Records (borrow_date, return_date);

-- Tạo một View tên là vw_overdue_loans hiển thị: Mã phiếu, Tên độc giả, Tên sách, Ngày mượn, Ngày dự kiến trả. View này chỉ chứa các bản ghi mà ngày hiện tại (CURDATE) đã vượt quá ngày dự kiến trả và sách chưa được trả.
CREATE VIEW vw_overdue_loans AS 
	SELECT loan_id, r.full_name, b.title, lr.borrow_date, lr.due_date 
		FROM Loan_Records lr 
			JOIN Readers r ON lr.reader_id = r.reader_id 
			JOIN Books b ON lr.book_id = b.book_id 
		WHERE CURDATE() > lr.due_date AND lr.return_date IS NULL;
     
     
-- Phần 5: TRIGGER
-- Viết Trigger trg_after_loan_insert. Khi một phiếu mượn mới được thêm vào bảng Loan_Records, hãy tự động trừ số lượng tồn kho (stock_quantity) của cuốn sách tương ứng trong bảng Books đi 1 đơn vị.
DELIMITER //
CREATE TRIGGER trg_after_loan_insert 
	AFTER INSERT ON Loan_Records 
	FOR EACH ROW 
	BEGIN
		UPDATE Books SET stock_quantity = stock_quantity - 1 WHERE book_id = NEW.book_id;
	END // 
    
-- Viết Trigger trg_prevent_delete_active_reader
CREATE TRIGGER trg_prevent_delete_active_reader 
	BEFORE DELETE ON Readers 
	FOR EACH ROW 
	BEGIN
		DECLARE msg VARCHAR(255);
		IF EXISTS (SELECT 1 FROM Loan_Records WHERE reader_id = OLD.reader_id AND return_date IS NULL) THEN
			SET msg = 'Không thể xóa độc giả đang mượn sách';
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = msg;
		END IF;
	END //
DELIMITER ;

--  Phần 6: STORED PROCEDURE
-- Viết Procedure sp_check_availability nhận vào Mã sách (p_book_id). Procedure trả về thông báo qua tham số OUT p_message
DELIMITER //
CREATE PROCEDURE sp_check_availability(IN p_book_id INT, OUT p_message VARCHAR(50))
BEGIN
    DECLARE stock INT;
    SELECT stock_quantity INTO stock 
		FROM Books 
		WHERE book_id = p_book_id;
    
    IF stock = 0 THEN
        SET p_message = 'Hết hàng';
    ELSEIF stock <= 5 THEN
        SET p_message = 'Sắp hết';
    ELSE
        SET p_message = 'Còn hàng';
    END IF;
END //

-- Viết Procedure sp_return_book_transaction để xử lý trả sách an toàn với Transaction
CREATE PROCEDURE sp_return_book_transaction(IN p_loan_id INT)
BEGIN
    DECLARE v_return_date DATE;
    DECLARE v_book_id INT;
    
    START TRANSACTION;
    SELECT return_date, book_id INTO v_return_date, v_book_id 
		FROM Loan_Records 
		WHERE loan_id = p_loan_id;
    
    IF v_return_date IS NOT NULL THEN
        ROLLBACK;
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Sách đã trả rồi';
    ELSE
        UPDATE Loan_Records SET return_date = CURDATE() WHERE loan_id = p_loan_id;
        UPDATE Books SET stock_quantity = stock_quantity + 1 WHERE book_id = v_book_id;
        COMMIT;
    END IF;
END //
DELIMITER ;






-- TEST DỮ LIỆU VÀ CHỨC NĂNG
-- Kiểm tra dữ liệu trong bảng các bảng
SELECT reader_id, full_name, email, phone_number, created_at FROM Readers;
SELECT card_id, reader_id, membership_level, expiry_date, citizen_id FROM Membership_Details;
SELECT category_id, category_name, description FROM Categories;
SELECT book_id, title, author, category_id, price, stock_quantity FROM Books;
SELECT loan_id, reader_id, book_id, borrow_date, due_date, return_date FROM Loan_Records;

-- Kiểm tra các phiếu mượn chưa trả
SELECT loan_id, reader_id, book_id, borrow_date, due_date FROM Loan_Records WHERE return_date IS NULL;

-- Kiểm tra tổng số lượng sách tồn kho của từng danh mục
SELECT c.category_name, SUM(b.stock_quantity) AS total_stock 
	FROM Categories c 
		JOIN Books b ON c.category_id = b.category_id 
	GROUP BY c.category_name;

-- Gọi view vw_overdue_loans
SELECT loan_id, full_name, title, borrow_date, due_date 
	FROM vw_overdue_loans;

-- Trigger trg_after_loan_insert
INSERT INTO Loan_Records (loan_id, reader_id, book_id, borrow_date, due_date, return_date) 
	VALUES (106, 5, 2, '2024-01-20', '2024-01-27', NULL);
SELECT book_id, title, stock_quantity 
	FROM Books 
	WHERE book_id = 2;

-- Trigger trg_prevent_delete_active_reader
DELETE FROM Readers WHERE reader_id = 1; -- xóa độc giả có ID = 1

-- Stored Procedure sp_check_availability
CALL sp_check_availability(1, @availability);

-- Stored Procedure sp_return_book_transaction
CALL sp_return_book_transaction(103); -- Trả sách với loan_id = 103

-- Kiểm tra lại dữ liệu trong bảng Loan_Records sau khi trả sách
SELECT loan_id, reader_id, book_id, borrow_date, due_date, return_date 
	FROM Loan_Records 
    WHERE loan_id = 103; -- Kiểm tra phiếu mượn đã được cập nhật