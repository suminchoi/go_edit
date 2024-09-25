<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="javax.servlet.http.HttpSession" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>게시글 상세 보기</title>
    <link rel="stylesheet" href="css/bootstrap.css">
    <link rel="stylesheet" href="css/ganjibutton.css">
    <style>
        body {
            margin: 0;
            height: 100vh;
            background-image: linear-gradient(to top, #e0f7fa, #b2ebf2);
            background-repeat: no-repeat;
            background-size: cover;
            background-attachment: fixed;
            font-family: "Jua", sans-serif;
        }
        .board-detail-container {
            max-width: 800px;
            margin: 50px auto;
            padding: 30px;
            background-color: #ffffff;
            border-radius: 10px;
            box-shadow: 0 4px 15px rgba(0, 0, 0, 0.1);
            position: relative;
        }
        .content-box {
            background-color: #f8f9fa;
            padding: 20px;
            border-radius: 8px;
            box-shadow: 0 2px 10px rgba(0, 0, 0, 0.1);
            margin-bottom: 20px;
        }
        .comment-form {
            background-color: #e0f2f1;
            padding: 20px;
            border-radius: 8px;
            box-shadow: 0 2px 10px rgba(0, 0, 0, 0.1);
            margin-bottom: 20px;
            margin-top: 30px;
        }
        .comment-box {
            background-color: #e8f5e9;
            padding: 15px;
            border-radius: 8px;
            box-shadow: 0 2px 10px rgba(0, 0, 0, 0.1);
            margin-bottom: 10px;
        }
        .content-box h5, .comment-form h5 {
            margin-bottom: 10px;
            font-size: 1.2rem;
            font-weight: bold;
            color: #333;
        }
        .content-box p, .comment-box p {
            margin: 0;
            padding: 5px 0;
            line-height: 1.6;
        }
        .btn-container {
            display: flex;
            justify-content: flex-end;
            gap: 10px;
            margin-top: 20px;
        }
        .btn-container .btn {
            padding: 10px 50px;
            font-size: 1rem;
        }
        .sk-logo {
            position: absolute;
            top: 10px;
            left: 10px;
            width: 100px;
            height: auto;
        }
    </style>
</head>
<body>
    <!-- SK 로고 이미지 추가 -->
    <img src="images/Shopping_Cart_Logo.png" alt="SK Logo" class="sk-logo">
    
    <div class="container board-detail-container">
        <%
            String loggedInUser = null;
            
            if (session != null) {
                loggedInUser = (String) session.getAttribute("username");
            }

            String idParam = request.getParameter("id");
            int id = 0;

            try {
                id = Integer.parseInt(idParam);
            } catch (NumberFormatException e) {
                out.println("올바르지 않은 ID 값입니다.");
                return;
            }

            Connection conn = null;
            PreparedStatement pstmt = null;
            ResultSet rs = null;

            try {
                // 데이터베이스 연결
                conn = DriverManager.getConnection("jdbc:mysql://10.0.2.37:3306/shopping-cart?useUnicode=true&characterEncoding=UTF-8", "dbuser", "1234");
                // PreparedStatement를 사용하여 안전하게 SQL 실행
                String sql = "SELECT * FROM board WHERE id = ?";
                pstmt = conn.prepareStatement(sql);
                pstmt.setInt(1, id);
                rs = pstmt.executeQuery();

                if (rs.next()) {
                    String fileName = rs.getString("file_name");
                    String postAuthor = rs.getString("author");
        %>
        <!-- 제목 박스 -->
        <div class="content-box">
            <h5>제목</h5>
            <p><%= rs.getString("title") %></p>
        </div>

        <!-- 작성자 박스 -->
        <div class="content-box">
            <h5>작성자</h5>
            <p><%= postAuthor %></p>
        </div>

        <!-- 작성일 박스 -->
        <div class="content-box">
            <h5>작성일</h5>
            <p><%= rs.getTimestamp("created_at") %></p>
        </div>

        <!-- 게시글 내용 박스 -->
        <div class="content-box">
            <h5>내용</h5>
            <p><%= rs.getString("content") %></p>
        </div>

        <!-- 첨부 파일 박스 -->
        <div class="content-box">
            <h5>첨부 파일</h5>
            <% if (fileName != null && !fileName.trim().isEmpty()) { %>
                <p><a href="fileDownload.jsp?id=<%= rs.getInt("id") %>"><%= fileName %></a></p>
            <% } else { %>
                <p>없음</p>
            <% } %>
        </div>

        <!-- 버튼 섹션 -->
        <div class="btn-container">
            <% if (loggedInUser != null && loggedInUser.equals(postAuthor)) { %>
                <a href="boardDelete.jsp?id=<%= rs.getInt("id") %>" class="btn btn-danger ganjibutton">삭제</a>
            <% } %>
            <a href="boardList.jsp" class="btn btn-secondary ganjibutton">목록으로</a>
        </div>

        <!-- 댓글 작성 폼 -->
        <div class="comment-form">
            <h5>댓글 작성</h5>
            <form action="commentWrite.jsp" method="post">
                <input type="hidden" name="board_id" value="<%= id %>">
                <div class="form-group">
                    <label for="commentAuthor">작성자</label>
                    <input type="text" class="form-control" id="commentAuthor" name="author" required>
                </div>
                <div class="form-group">
                    <label for="commentContent">댓글 내용</label>
                    <textarea class="form-control" id="commentContent" name="content" rows="3" required></textarea>
                </div>
                <button type="submit" class="btn btn-primary">댓글 작성</button>
            </form>
        </div>

        <!-- 댓글 목록 -->
        <div class="content-box">
            <h5>댓글</h5>
            <%
                pstmt = conn.prepareStatement("SELECT * FROM comments WHERE board_id = ? ORDER BY created_at DESC");
                pstmt.setInt(1, id);
                ResultSet commentRs = pstmt.executeQuery();
                while (commentRs.next()) {
            %>
                <div class="comment-box">
                    <p><strong><%= commentRs.getString("author") %>:</strong> <%= commentRs.getString("content") %> <span style="font-size: 0.8rem;">(<%= commentRs.getTimestamp("created_at") %>)</span></p>
                </div>
            <%
                }
                commentRs.close();
            %>
        </div>
        <%
            } else {
                out.println("게시글을 찾을 수 없습니다.");
            }
        } catch (SQLException e) {
            e.printStackTrace();
            out.println("데이터베이스 오류가 발생했습니다: " + e.getMessage());
        } finally {
            if (rs != null) try { rs.close(); } catch (SQLException ignore) {}
            if (pstmt != null) try { pstmt.close(); } catch (SQLException ignore) {}
            if (conn != null) try { conn.close(); } catch (SQLException ignore) {}
        }
        %>
    </div>
</body>
</html>