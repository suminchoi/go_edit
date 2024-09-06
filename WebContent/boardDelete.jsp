<%@ page import="java.sql.*" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<%
    // 삭제할 게시글의 ID를 가져옴
    String idParam = request.getParameter("id");
    int id = 0;

    // ID 값이 잘못된 경우를 대비하여 예외 처리
    try {
        if (idParam != null) {
            id = Integer.parseInt(idParam);
        } else {
            out.println("유효하지 않은 게시글 ID입니다.");
            return;
        }
    } catch (NumberFormatException e) {
        out.println("유효하지 않은 형식의 ID입니다.");
        return;
    }

    // 데이터베이스 연결 및 삭제 쿼리 실행
    Connection conn = null;
    PreparedStatement pstmt = null;

    try {
        // 데이터베이스 연결
        conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/shopping-cart?useUnicode=true&characterEncoding=utf8", "root", "1234");

        // 삭제 쿼리 실행
        String sql = "DELETE FROM board WHERE id = ?";
        pstmt = conn.prepareStatement(sql);
        pstmt.setInt(1, id);
        int rowsAffected = pstmt.executeUpdate();

        if (rowsAffected > 0) {
            // 삭제 성공
            response.sendRedirect("boardList.jsp");
        } else {
            // 삭제할 데이터가 없는 경우
            out.println("삭제할 게시글이 없습니다.");
        }
    } catch (SQLException e) {
        e.printStackTrace();
        out.println("게시글 삭제 중 오류가 발생했습니다: " + e.getMessage());
    } finally {
        // 자원 정리
        if (pstmt != null) pstmt.close();
        if (conn != null) conn.close();
    }
%>
