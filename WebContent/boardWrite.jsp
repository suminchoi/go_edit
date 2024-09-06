<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="javax.servlet.http.HttpSession" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>게시글 작성</title>
    <link rel="stylesheet" href="css/bootstrap.css">
    <link rel="stylesheet" href="css/ganjibutton.css"> <!-- ganjibutton.css 스타일 적용 -->
    <style>
        body {
            margin: 0;
            height: 100vh;
            background-image: linear-gradient(to top, #d9afd9 0%, #97d9e1 100%);
            background-repeat: no-repeat;
            background-size: cover;
            background-attachment: fixed;
            font-family: "Jua", sans-serif;
        }
        .board-write-container {
            max-width: 800px;
            margin: 50px auto;
            padding: 30px;
            background-color: rgba(255, 255, 255, 0.8);
            border-radius: 10px;
            box-shadow: 0 4px 15px rgba(0, 0, 0, 0.1);
            position: relative;
        }
        .title-section {
            text-align: center;
            font-size: 3rem;
            font-weight: bold;
            margin-top: 20px;
            animation: rainbow 2s infinite alternate;
            cursor: pointer;
        }
        @keyframes rainbow {
            0% { color: #ff0000; }
            14% { color: #ff7f00; }
            28% { color: #ffff00; }
            42% { color: #00ff00; }
            57% { color: #0000ff; }
            71% { color: #4b0082; }
            85% { color: #9400d3; }
            100% { color: #ff0000; }
        }
        .btn-container {
            display: flex;
            justify-content: space-between;
            gap: 10px; /* 버튼 사이 간격 조정 */
            margin-top: 20px;
        }
        .sk-logo {
            position: absolute;
            top: 10px;
            left: 10px;
            width: 100px; /* 로고 크기 조정 */
            height: auto;
        }
    </style>
/head>
<body>
    <!-- SK 로고 이미지 추가 -->
    <img src="images/sk_shieldus_comm_rgb_kr.png" alt="SK Logo" class="sk-logo">
    
    <div class="container board-write-container">
        <h2 class="title-section">게시글 작성</h2>
        
        <%
            // 세션에서 로그인한 사용자 정보 가져오기
            String username = null;
            
            if (session != null) {
                username = (String) session.getAttribute("username"); // 세션에서 사용자 이름 가져오기
            }

            // 로그인 정보가 없을 경우 로그인 페이지로 리다이렉트
            if (username == null) {
                response.sendRedirect("login.jsp");
                return;
            }
        %>
        
        <form action="boardWriteProcess.jsp" method="post" enctype="multipart/form-data">
            <div class="form-group">
                <label for="title">제목</label>
                <input type="text" class="form-control" id="title" name="title" placeholder="제목을 입력하세요" required>
            </div>
            <div class="form-group">
                <label for="author">작성자</label>
                <!-- 로그인된 사용자를 자동으로 설정하고, 읽기 전용으로 만듭니다 -->
                <input type="text" class="form-control" id="author" name="author" value="<%= username %>" readonly>
            </div>
            <div class="form-group">
                <label for="content">내용</label>
                <textarea class="form-control" id="content" name="content" rows="5" placeholder="내용을 입력하세요" required></textarea>
            </div>
            <div class="form-group">
                <label for="uploadFile">파일 업로드</label>
                <input type="file" class="form-control-file" id="uploadFile" name="uploadFile">
            </div>
            <div class="btn-container">
                <button type="submit" class="btn ganjibutton" style="flex: 1;">작성 완료</button>
                <a href="boardList.jsp" class="btn ganjibutton" style="flex: 1;">목록으로</a>
            </div>
        </form>
    </div>
</body>
</html>
