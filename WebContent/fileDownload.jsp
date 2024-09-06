<%@ page import="java.io.*, java.sql.*" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<%
    // 파라미터로부터 파일 ID 받기
    String fileId = request.getParameter("id");

    // 데이터베이스 연결 설정
    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;

    try {
        // 데이터베이스 연결
        conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/shopping-cart?useUnicode=true&characterEncoding=utf8", "root", "1234");

        // 파일 정보를 가져오는 SQL 쿼리
        String sql = "SELECT file_name, file_content FROM board WHERE id = ?";
        pstmt = conn.prepareStatement(sql);
        pstmt.setString(1, fileId);
        rs = pstmt.executeQuery();

        if (rs.next()) {
            // 파일 이름과 내용을 가져오기
            String fileName = rs.getString("file_name");

            // 파일 이름이 NULL이거나 빈 값일 경우 기본 파일 이름 설정
            if (fileName == null || fileName.trim().isEmpty()) {
                fileName = "downloaded_file.bin"; // 기본 파일 이름 설정
            }

            InputStream fileContent = rs.getBlob("file_content").getBinaryStream();

            // 파일 이름을 URL 인코딩하여 Content-Disposition에 설정
            String encodedFileName = java.net.URLEncoder.encode(fileName, "UTF-8").replaceAll("\\+", "%20");

            // 다운로드 설정
            response.setContentType(getServletContext().getMimeType(fileName)); // MIME 타입 설정
            response.setHeader("Content-Disposition", "attachment; filename*=UTF-8''" + encodedFileName); // 파일 이름 설정

            // 파일 내용을 클라이언트로 전송
            OutputStream fileOut = response.getOutputStream();
            byte[] buffer = new byte[1024];
            int bytesRead;

            while ((bytesRead = fileContent.read(buffer)) != -1) {
                fileOut.write(buffer, 0, bytesRead);
            }

            fileContent.close();
            fileOut.close();
        } else {
            out.println("파일을 찾을 수 없습니다.");
        }
    } catch (Exception e) {
        e.printStackTrace();
        out.println("파일 다운로드 중 오류가 발생했습니다: " + e.getMessage());
    } finally {
        // 자원 정리
        if (rs != null) rs.close();
        if (pstmt != null) pstmt.close();
        if (conn != null) conn.close();
    }
%>
