/*
Bài 4: Xây dựng Hệ thống Quản lý Cửa hàng Bán điện thoại
Mô tả hệ thống:
Xây dựng một hệ thống quản lý cửa hàng bán điện thoại đơn giản, cho phép:
•	Quản lý thông tin điện thoại
•	Quản lý hóa đơn bán hàng
•	Tính toán doanh thu, lợi nhuận
Yêu cầu thiết kế:
1. Lớp DienThoai (Sản phẩm):
•	Thuộc tính private: 
o	Mã điện thoại (String)
o	Tên điện thoại (String)
o	Hãng sản xuất (String)
o	Giá nhập (double)
o	Giá bán (double)
o	Số lượng tồn kho (int)
o	Trạng thái (boolean - còn kinh doanh hay không)
•	Yêu cầu: 
o	Constructor đầy đủ tham số
o	Getter/setter cho tất cả thuộc tính với validation: 
	Mã điện thoại: không rỗng, định dạng "DT-XXX"
	Tên và hãng: không rỗng
	Giá nhập/bán: > 0, giá bán > giá nhập
	Số lượng tồn: >= 0
o	Phương thức tính lợi nhuận dự kiến
o	Phương thức hiển thị thông tin
o	Phương thức kiểm tra có thể bán không (còn hàng và đang kinh doanh)
2. Lớp HoaDon (Hóa đơn bán hàng):
•	Thuộc tính private: 
o	Mã hóa đơn (String)
o	Ngày bán (DateTime)
o	Điện thoại được bán (DienThoai)
o	Số lượng mua (int)
o	Giá bán thực tế (double)
o	Tên khách hàng (String)
o	Số điện thoại khách (String)
•	Yêu cầu: 
o	Constructor đầy đủ tham số
o	Getter/setter với validation: 
	Mã hóa đơn: không rỗng, định dạng "HD-XXX"
	Ngày bán: không sau ngày hiện tại
	Số lượng mua: > 0 và <= tồn kho
	Giá bán thực tế: > 0
	Thông tin khách: không rỗng, SĐT đúng định dạng
o	Phương thức tính tổng tiền
o	Phương thức tính lợi nhuận thực tế
o	Phương thức hiển thị thông tin hóa đơn
3. Lớp CuaHang (Quản lý):
•	Thuộc tính private: 
o	Tên cửa hàng (String)
o	Địa chỉ (String)
o	Danh sách điện thoại (List<DienThoai>)
o	Danh sách hóa đơn (List<HoaDon>)
•	Yêu cầu: 
o	Constructor với tên và địa chỉ
o	Các phương thức quản lý điện thoại: 
	Thêm điện thoại mới
	Cập nhật thông tin điện thoại
	Ngừng kinh doanh điện thoại
	Tìm kiếm điện thoại (theo mã, tên, hãng)
	Hiển thị danh sách điện thoại
o	Các phương thức quản lý hóa đơn: 
	Tạo hóa đơn mới (tự động cập nhật tồn kho)
	Tìm kiếm hóa đơn (theo mã, ngày, khách hàng)
	Hiển thị danh sách hóa đơn
o	Các phương thức thống kê: 
	Tính tổng doanh thu theo khoảng thời gian
	Tính tổng lợi nhuận theo khoảng thời gian
	Thống kê top điện thoại bán chạy
	Thống kê tồn kho
Yêu cầu testing:
Xây dựng lớp Test để kiểm thử các tính năng:
1.	Tạo và quản lý thông tin điện thoại: 
o	Thêm điện thoại mới
o	Cập nhật thông tin
o	Kiểm tra validation
2.	Tạo và quản lý hóa đơn: 
o	Tạo hóa đơn hợp lệ
o	Kiểm tra các ràng buộc (tồn kho, validation)
o	Tính toán tiền và lợi nhuận
3.	Thống kê báo cáo: 
o	Doanh thu theo thời gian
o	Lợi nhuận theo thời gian
o	Top bán chạy
o	Báo cáo tồn kho
Yêu cầu chung:
1.	Áp dụng tính đóng gói: 
o	Thuộc tính private
o	Getter/setter với validation
2.	Xử lý ngoại lệ: 
o	Validation dữ liệu
o	Kiểm tra tồn kho
o	Kiểm tra ràng buộc nghiệp vụ
3.	Clean code: 
o	Đặt tên biến/phương thức rõ ràng
o	Comment đầy đủ
o	Tổ chức code hợp lý
Gợi ý cách làm:
1.	Phân tích yêu cầu và thiết kế lớp
2.	Xây dựng từng lớp theo thứ tự: DienThoai → HoaDon → CuaHang
3.	Viết các phương thức cơ bản trước, nâng cao sau
4.	Tạo dữ liệu test và kiểm thử từng chức năng
Lưu ý: Đây là bài tập thực hành, sinh viên cần tự implement mã nguồn.


*/