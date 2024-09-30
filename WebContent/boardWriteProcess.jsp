<%@ page import="java.io.*, java.sql.*, javax.servlet.http.*, javax.servlet.annotation.MultipartConfig" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<%
    request.setCharacterEncoding("UTF-8"); // 인코딩 설정 추가

    // 폼 데이터 가져오기
    String title = request.getParameter("title");
    String content = request.getParameter("content");
    String author = request.getParameter("author");

    // 기본값 설정
    if (title == null || title.trim().isEmpty()) {
        title = "Untitled";
    }
    if (content == null) {
        content = "";
    }
    if (author == null) {
        author = "Anonymous";
    }

    // 파일 업로드 처리
    Part filePart = request.getPart("uploadFile");
    String fileName = "";
    long fileSize = 0;
    InputStream fileContent = null;

    String uploadDir = getServletContext().getRealPath("/uploads"); // uploadDir 변수 선언
    File uploadDirFile = new File(uploadDir);
    if (!uploadDirFile.exists()) {
        uploadDirFile.mkdirs(); // 디렉토리가 없으면 생성
    }

    // 파일 업로드 처리
    if (filePart != null && filePart.getSize() > 0) {
        fileName = filePart.getSubmittedFileName();
        fileSize = filePart.getSize();
        fileContent = filePart.getInputStream();

        // 파일을 서버 디렉토리에 저장
        File file = new File(uploadDir + File.separator + fileName);
        try (FileOutputStream fos = new FileOutputStream(file)) {
            byte[] buffer = new byte[1024];
            int bytesRead;
            while ((bytesRead = fileContent.read(buffer)) != -1) {
                fos.write(buffer, 0, bytesRead); // 파일 저장
            }
        }
    }

    // 대용량 텍스트 처리 (제목 및 내용의 크기 제한 제거)
    if (title.length() > 50000 || content.length() > 1000000) {
        out.println("Warning: You are entering large data that might cause issues.");
    }

    // 데이터베이스에 저장
    try (Connection conn = DriverManager.getConnection("jdbc:mysql://18.183.202.201:3306/shopping-cart?useUnicode=true&characterEncoding=utf8", "dbuser", "1234")) {
        String sql = "INSERT INTO board (title, author, content, file_name, file_size, file_content) VALUES (?, ?, ?, ?, ?, ?)";
        try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setString(1, title);
            pstmt.setString(2, author);
            pstmt.setString(3, content);
            pstmt.setString(4, fileName);
            pstmt.setLong(5, fileSize);

            // 파일이 있을 경우 BLOB으로 저장
            if (fileContent != null) {
                pstmt.setBlob(6, new FileInputStream(new File(uploadDir + File.separator + fileName)));
            } else {
                pstmt.setNull(6, java.sql.Types.BLOB);
            }

            pstmt.executeUpdate(); // 데이터베이스에 저장
        }
    } catch (Exception e) {
        e.printStackTrace();
        out.println("게시글 저장 중 오류가 발생했습니다.");
    }

    // 게시글 목록 페이지로 리다이렉트
    response.sendRedirect("boardList.jsp");
%>
