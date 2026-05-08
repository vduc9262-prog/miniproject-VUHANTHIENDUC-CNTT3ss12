CREATE DATABASE social_network_ss12;
USE social_network_ss12;

CREATE TABLE users(
    user_id INT PRIMARY KEY AUTO_INCREMENT,
    username VARCHAR(50) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE posts(
    post_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id int,
    content text not null,
    created_at DateTime default current_timestamp,
    foreign key (user_id) references users (user_id) on delete cascade
);

CREATE TABLE comments(
    comment_id INT PRIMARY KEY AUTO_INCREMENT,
    post_id INT,
    user_id INT,
    content TEXT NOT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (post_id) REFERENCES posts(post_id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
);

CREATE TABLE friends(
    user_id INT,
    friend_id INT,
    status VARCHAR(20) CHECK (status IN ('pending','accepted')),
    PRIMARY KEY (user_id, friend_id),
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (friend_id) REFERENCES users(user_id) ON DELETE CASCADE,
    CHECK (user_id != friend_id)
);

INSERT INTO users(username,password, email) 
VALUES 
('Vu Anh Duc','123','vuanhduc@gmail.com'),
('Nguyen Hai Duong','123','haiduong@gmail.com'),
('Minh Hieu','123','minhhieu@gmail.com');

-- Posts
INSERT INTO posts(user_id, content) VALUES
(1, 'Hello world'),
(2, 'My first post'),
(3, 'Good morning');


-- Comments
INSERT INTO comments(user_id, post_id, content) VALUES
(2,1,'Nice'),
(3,1,'Great'),
(1,2,'Cool');

-- Friends
INSERT INTO friends(user_id, friend_id, status) VALUES
(1,2,'accepted'),
(1,3,'accepted'),
(2,3,'pending');

-- REQ-01: Hiển thị hồ sơ người dùng an toàn
-- Mô tả: Hệ thống phải cung cấp một khung nhìn (vw_UserInfo) để Frontend truy xuất danh sách người dùng.
-- Điều kiện ràng buộc: Khung nhìn này tuyệt đối không được chứa cột password. Chỉ bao gồm: user_id, username, email, created_at.

create view vw_UserInfo as
select  user_id, username, email, created_at
from users;

select * from vw_UserInfo;


-- REQ-02: Báo cáo tương tác bài viết
-- Mô tả: Hệ thống phải cung cấp một khung nhìn (vw_PostStatistics) để thống kê lượng tương tác.
-- Dữ liệu đầu ra: post_id, Nội dung bài viết, Tên người đăng, Tổng số Like, Tổng số Comment. Yêu cầu
--  hiển thị cả những bài viết chưa có lượt tương tác nào.


create view vw_PostStatistics as
select post_id, content,  username , count(user_id), count(comment_id)
from posts p 
inner join users u 
on u.user_id = p.user_id 
left join likes l 
on l.post_id = p.post_id
left join comments c
on c.post_id = p.post_id
group by p.post_id;


DELIMITER $$

CREATE PROCEDURE sp_AddUser(
    IN p_username varchar(50),
    IN p_password varchar(250),
    IN p_email varchar(150),
    out message varchar (100)
)
BEGIN
     if p_email in (
      select email from users 
     )
     then set message = 'email đã đc sử dụng ';
     else 
     insert into users(username,password,email)
     values (p_username,p_password,p_email);
     end if;
	
END $$

DELIMITER ;



DELIMITER //
CREATE PROCEDURE sp_CreatePost(
    IN p_user_id INT,
    IN p_content TEXT
)
BEGIN
    INSERT INTO Posts (user_id, content) 
    VALUES (p_user_id, p_content);
    
    -- Trả về ID vừa tạo ngay lập tức
    SELECT LAST_INSERT_ID() AS post_id;
END //
DELIMITER ;




DELIMITER //
CREATE PROCEDURE sp_GetFriendsPaging(
    IN p_user_id INT,
    IN p_limit INT,
    IN p_offset INT
)
BEGIN
    SELECT u.username, u.email
    FROM Friends f
    JOIN Users u ON f.friend_id = u.user_id
    WHERE f.user_id = p_user_id 
      AND f.status = 'accepted'
    LIMIT p_limit OFFSET p_offset;
END //
DELIMITER ;	


CALL sp_AddUser('thienduc', '123456', 'thienduc@gmail.com');
SET @new_post_id = 0;
CALL sp_CreatePost(1,'Bài viết mới',@new_post_id);
SELECT @new_post_id;
CALL sp_GetFriends(1, 10, 0);
















