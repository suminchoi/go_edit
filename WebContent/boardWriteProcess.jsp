<%@ page import="java.io.*, java.sql.*, javax.servlet.http.*, javax.servlet.annotation.MultipartConfig" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<%
    request.setCharacterEncoding("UTF-8"); // 인코딩 설정 추가
    String title = request.getParameter("title");
    String content = request.getParameter("content");
    String author = request.getParameter("author");

    Part filePart = request.getPart("uploadFile");
    String fileName = "";
    long fileSize = 0;
    InputStream fileContent = null;

    // 파일 처리 관련 코드 (크기와 파일 유형 제한을 모두 제거)
    if (filePart != null) {
        fileName = filePart.getSubmittedFileName();
        fileSize = filePart.getSize();  // 파일 크기 제한 없음
        fileContent = filePart.getInputStream();

        // 파일명 검증 제거 (모든 파일명 허용)
        // 파일 유형 검사 제거 (모든 파일 유형 허용, 악성 스크립트 업로드 가능)
    }

    // 대용량 텍스트 입력 허용 (길이에 대한 제한을 없앰)
    if (title.length() > 50000 || content.length() > 1000000) { // 매우 큰 데이터를 허용
        out.println("Warning: You are entering large data that might cause issues.");
    }

    try (Connection conn = DriverManager.getConnection("jdbc:mysql://10.0.2.37:3306/shopping-cart?useUnicode=true&characterEncoding=utf8", "dbuser", "1234")) {
        // 데이터베이스에 게시글 저장
        String sql = "INSERT INTO board (title, author, content, file_name, file_size, file_content) VALUES (?, ?, ?, ?, ?, ?)";
        PreparedStatement pstmt = conn.prepareStatement(sql);
        pstmt.setString(1, title);
        pstmt.setString(2, author);
        pstmt.setString(3, content);
        pstmt.setString(4, fileName);
        pstmt.setLong(5, fileSize);
        
        if (fileContent != null) {
            pstmt.setBlob(6, fileContent);  // 대용량 파일 업로드 허용 (크기 제한 없음)
        } else {
            pstmt.setNull(6, java.sql.Types.BLOB);
        }
        pstmt.executeUpdate();
    } catch (Exception e) {
        e.printStackTrace();
        out.println("Error: 게시글 저장 중 오류가 발생했습니다.");
    }

    // 게시글 목록으로 리다이렉트
    response.sendRedirect("boardList.jsp");
%>
