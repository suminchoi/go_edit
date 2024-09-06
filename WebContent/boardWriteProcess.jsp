<%@ page import="java.io.*, java.sql.*, javax.servlet.http.*, javax.servlet.annotation.MultipartConfig" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<%
    request.setCharacterEncoding("UTF-8"); // 인코딩 설정 추가
    String title = request.getParameter("title");
    String content = request.getParameter("content");
    String author = request.getParameter("author");

    if (title == null || title.trim().isEmpty()) {
        title = "Untitled";
    }
    if (content == null) {
        content = "";
    }
    if (author == null) {
        author = "Anonymous";
    }

    Part filePart = request.getPart("uploadFile");
    String fileName = "";
    long fileSize = 0;
    InputStream fileContent = null;

    if (filePart != null) {
        fileName = filePart.getSubmittedFileName();
        fileSize = filePart.getSize();
        fileContent = filePart.getInputStream();
    }

    try (Connection conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/shopping-cart?useUnicode=true&characterEncoding=utf8", "root", "1234")) {
        String sql = "INSERT INTO board (title, author, content, file_name, file_size, file_content) VALUES (?, ?, ?, ?, ?, ?)";
        PreparedStatement pstmt = conn.prepareStatement(sql);
        pstmt.setString(1, title);
        pstmt.setString(2, author);
        pstmt.setString(3, content);
        pstmt.setString(4, fileName);
        pstmt.setLong(5, fileSize);
        if (fileContent != null) {
            pstmt.setBlob(6, fileContent);
        } else {
            pstmt.setNull(6, java.sql.Types.BLOB);
        }
        pstmt.executeUpdate();
        pstmt.close();
    } catch (Exception e) {
        e.printStackTrace();
        out.println("게시글 저장 중 오류가 발생했습니다.");
    }

    response.sendRedirect("boardList.jsp");
%>
