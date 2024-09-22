package com.shashi.srv;

import java.io.IOException;
import javax.servlet.RequestDispatcher;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import com.shashi.service.impl.UserServiceImpl;

@WebServlet("/LoginSrv")
public class LoginSrv extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String userName = request.getParameter("username");
        String password = request.getParameter("password");
        String userType = request.getParameter("usertype");
        response.setContentType("text/html");

        String status = "Login Denied! Invalid Username or password.";

        // 로그인 검증 로직
        UserServiceImpl userService = new UserServiceImpl();
        status = userService.isValidCredential(userName, password); // 로그인 검증

        // 디버깅을 위한 로그
        System.out.println("Login Status: " + status);

        if (status.equals("valid")) {
            // 세션 생성 및 사용자 정보 설정
            HttpSession session = request.getSession(); // 세션 생성 또는 가져오기
            session.setAttribute("username", userName);
            session.setAttribute("usertype", userType);

            // 세션 유효 시간 설정 (30분)
            session.setMaxInactiveInterval(30 * 60);

            // 사용자 유형에 따라 리디렉션 처리
            if (userType.equals("admin")) {
                response.sendRedirect("adminViewProduct.jsp");
            } else {
                response.sendRedirect("userHome.jsp");
            }
        } else {
            // 로그인 실패 시 다시 로그인 페이지로 이동
            RequestDispatcher rd = request.getRequestDispatcher("login.jsp?message=" + status);
            rd.forward(request, response);
        }
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doGet(request, response);
    }
}
