<%@ page language="java" contentType="text/html; charset=UTF-8"%>
<%@ page import="java.sql.*"%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>게시판</title>
    <link rel="stylesheet" href="css/bootstrap.css">
    <link rel="stylesheet" href="css/ganjibutton.css">
    <style>
        @import url('https://fonts.googleapis.com/css2?family=Jua&display=swap');
        body {
            font-family: 'Jua', sans-serif;
            color: #000;
        }

        .header-image {
            position: absolute;
            top: 10px;
            left: 10px;
            width: 150px;
            transition: transform 0.6s;
            transform-style: preserve-3d;
        }

        .header-image:hover {
            transform: rotateY(180deg);
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

        .search-section {
            display: flex;
            align-items: center;
            padding: 10px;
            background-color: rgba(255, 255, 255, 0);
            border: 2px solid #333;
            border-radius: 10px;
            box-shadow: 0 4px 15px rgba(0, 0, 0, 0.2);
            margin-bottom: 20px;
            width: fit-content;
            gap: 10px;
            margin-left: 150px;
        }

        .search-inputs {
            display: flex;
            flex-grow: 1;
            gap: 10px;
        }

        .search-section .form-control,
        .search-section select {
            border-radius: 5px;
            border: 1px solid #ccc;
            padding: 8px;
            background-color: #fff;
            color: #000;
        }

        .btn {
            border: none;
            text-align: center;
            cursor: pointer;
            text-transform: uppercase;
            outline: none;
            overflow: hidden;
            position: relative;
            color: #fff;
            font-weight: 700;
            font-size: 15px;
            background-color: #222;
            padding: 17px 30px;
            box-shadow: 0 5px 15px rgba(0, 0, 0, 0.3);
            transition: all 0.3s ease;
            border-radius: 5px;
        }

        .btn:hover {
            box-shadow: 0 8px 20px rgba(0, 0, 0, 0.4);
            transform: translateY(-2px);
        }

        .btn-search, .btn-write {
            margin-left: 0px;
        }

        .btn-main {
            padding: 17px 30px;
            margin-left: 10px;
        }

        .action-buttons {
            margin-bottom: 20px;
        }

        .pagination {
            display: flex;
            justify-content: center;
            margin-top: 20px;
        }

        .pagination a {
            color: #333;
            padding: 10px 15px;
            text-decoration: none;
            border: 1px solid #ddd;
            margin: 0 5px;
            border-radius: 5px;
            transition: background-color 0.3s;
        }

        .pagination a:hover {
            background-color: #ddd;
        }

        .pagination .active {
            background-color: #333;
            color: #fff;
            border: 1px solid #333;
        }

        .board-table {
            border: 2px solid #000;
            border-collapse: collapse;
        }

        .board-table th, .board-table td {
            border: 1px solid #000 !important;
            padding: 8px;
            text-align: center;
            background-clip: padding-box;
        }
    </style>
    <script>
        function searchPosts() {
            const keyword = document.querySelector('input[name="searchKeyword"]').value;
            const type = document.querySelector('select[name="searchType"]').value;
            const startDate = document.querySelector('input[name="startDate"]').value;
            const endDate = document.querySelector('input[name="endDate"]').value;

            const queryParams = new URLSearchParams({
                searchKeyword: keyword,
                searchType: type,
                startDate: startDate,
                endDate: endDate
            });

            window.location.href = `boardList.jsp?${queryParams.toString()}`;
        }

        function goToBoard() {
            window.location.href = "boardList.jsp";
        }
    </script>
</head>
<body>
    <img src="images/sk_shieldus_comm_rgb_kr.png" alt="SK 쉴더스 로고" class="header-image">

    <div class="title-section" onclick="goToBoard()">
        게시판
    </div>

    <div class="container mt-4 board-content">
        <form class="search-section" method="get" action="boardList.jsp">
            <div class="search-inputs">
                <input type="text" name="searchKeyword" placeholder="검색어 입력" class="form-control">
                <select name="searchType" class="form-control">
                    <option value="title">제목</option>
                    <option value="author">작성자</option>
                </select>
                <input type="date" name="startDate" class="form-control" placeholder="시작 날짜">
                <input type="date" name="endDate" class="form-control" placeholder="종료 날짜">
            </div>
            <button type="submit" class="btn btn-search"><span>검색</span></button>
            <a href="userHome.jsp" class="btn btn-main"><span>메인 홈</span></a>
        </form>

        <div class="action-buttons">
            <a href="boardWrite.jsp" class="btn btn-write"><span>글쓰기</span></a>
        </div>

        <%
            int pageSize = 10;  // 한 페이지에 표시할 게시글 수
            int pageNumber = 1; // 현재 페이지 번호
            if (request.getParameter("page") != null) {
                pageNumber = Integer.parseInt(request.getParameter("page"));
            }
            int startRow = (pageNumber - 1) * pageSize;

            Connection conn = null;
            Statement stmt = null;
            ResultSet rs = null;

            String searchKeyword = request.getParameter("searchKeyword");
            String searchType = request.getParameter("searchType");
            String startDate = request.getParameter("startDate");
            String endDate = request.getParameter("endDate");

            // SQL 쿼리 시작
            String sql = "SELECT * FROM board WHERE 1=1";

            // 검색 조건에 따른 쿼리 수정
            if (searchKeyword != null && !searchKeyword.isEmpty()) {
                sql += " AND " + searchType + " LIKE '%" + searchKeyword + "%'";
            }

            // 날짜 필터링 - 수정된 부분
            if (startDate != null && !startDate.isEmpty() && endDate != null && !endDate.isEmpty()) {
                sql += " AND created_at BETWEEN '" + startDate + "' AND '" + endDate + "'";
            }

            sql += " ORDER BY created_at DESC LIMIT " + startRow + ", " + pageSize;

            try {
                conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/shopping-cart?useUnicode=true&characterEncoding=utf8", "root", "1234");
                stmt = conn.createStatement();
                rs = stmt.executeQuery(sql);

                // 게시글 목록 출력
        %>
                <table class="table table-striped jua-regular board-table">
                    <thead>
                        <tr>
                            <th>번호</th>
                            <th>제목</th>
                            <th>작성자</th>
                            <th>작성일</th>
                            <th>파일</th>
                        </tr>
                    </thead>
                    <tbody>
                        <%
                        while (rs.next()) {
                            String fileName = rs.getString("file_name");
                            %>
                            <tr>
                                <td><%= rs.getInt("id") %></td>
                                <td><a href="boardDetail.jsp?id=<%= rs.getInt("id") %>"><%= rs.getString("title") %></a></td>
                                <td><%= rs.getString("author") %></td>
                                <td><%= rs.getTimestamp("created_at") %></td>
                                <td><%= fileName != null ? fileName : "없음" %></td>
                            </tr>
                            <%
                        }
                        %>
                    </tbody>
                </table>

                <div class="pagination">
                    <%
                    // 페이지네이션 계산을 위한 전체 게시글 수 쿼리
                    String countSql = "SELECT COUNT(*) AS total FROM board WHERE 1=1";

                    // 검색 조건이 있으면 동일하게 적용
                    if (searchKeyword != null && !searchKeyword.isEmpty()) {
                        countSql += " AND " + searchType + " LIKE '%" + searchKeyword + "%'";
                    }
                    if (startDate != null && !startDate.isEmpty() && endDate != null && !endDate.isEmpty()) {
                        countSql += " AND created_at BETWEEN '" + startDate + "' AND '" + endDate + "'";
                    }

                    // 총 게시글 수 조회
                    ResultSet countRs = stmt.executeQuery(countSql);
                    countRs.next();
                    int totalPosts = countRs.getInt("total");

                    // 총 페이지 수 계산
                    int totalPages = (int) Math.ceil(totalPosts / (double) pageSize);

                    // 페이지 번호 출력
                    for (int i = 1; i <= totalPages; i++) {
                        if (i == pageNumber) {
                            %>
                            <a href="#" class="active"><%= i %></a>
                            <%
                        } else {
                            %>
                            <a href="boardList.jsp?page=<%= i %>"><%= i %></a>
                            <%
                        }
                    }
                    countRs.close();
                    %>
                </div>

        <%
            } catch (SQLException e) {
                e.printStackTrace();
                out.println("게시글을 불러오는 중 오류가 발생했습니다: " + e.getMessage());
            } finally {
                if (rs != null) try { rs.close(); } catch (SQLException ignore) {}
                if (stmt != null) try { stmt.close(); } catch (SQLException ignore) {}
                if (conn != null) try { conn.close(); } catch (SQLException ignore) {}
            }
        %>
    </div>
</body>
</html>
