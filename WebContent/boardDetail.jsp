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
    <link rel="stylesheet" href="css/ganjibutton.css"> <!-- ganjibutton.css 스타일 적용 -->
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
            margin-top: 30px; /* 댓글 작성 칸 위 간격 추가 */
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
            padding: 10px 50px; /* 버튼 크기 키움 */
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
    <img src="images/sk_shieldus_comm_rgb_kr.png" alt="SK Logo" class="sk-logo">
    
    <div class="container board-detail-container">
        <%
            // 로그인한 사용자 정보 가져오기
        
            String loggedInUser = null;
            
            if (session != null) {
                loggedInUser = (String) session.getAttribute("username"); // 세션에서 사용자 이름 가져오기
            }

            int id = Integer.parseInt(request.getParameter("id"));
            // UTF-8 인코딩 설정 추가
            Connection conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/shopping-cart?useUnicode=true&characterEncoding=UTF-8", "root", "1234");
            PreparedStatement pstmt = conn.prepareStatement("SELECT * FROM board WHERE id = ?");
            pstmt.setInt(1, id);
            ResultSet rs = pstmt.executeQuery();

            if (rs.next()) {
                String fileName = rs.getString("file_name");
                String postAuthor = rs.getString("author"); // 게시글 작성자 정보 가져오기
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
                <!-- 삭제 버튼은 로그인한 사용자와 작성자가 동일할 때만 표시 -->
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
            %>
        </div>
        <%
            }
            conn.close();
        %>
    </div>
</body>
</html>
