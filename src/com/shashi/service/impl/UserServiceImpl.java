package com.shashi.service.impl;

import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import com.shashi.utility.DBUtil;

public class UserServiceImpl {

    public String isValidCredential(String emailId, String password) {
        String status = "Login Denied! Incorrect Username or Password";
        Connection con = DBUtil.provideConnection();
        Statement stmt = null;
        ResultSet rs = null;

        try {
            // SQL 쿼리 출력 (디버깅용)
            String query = "SELECT * FROM user WHERE email='" + emailId + "' AND password='" + password + "'";
            System.out.println("Executing query: " + query); // 쿼리 확인
            
            stmt = con.createStatement();
            rs = stmt.executeQuery(query);

            if (rs.next()) {
                status = "valid";  // 로그인 성공
                System.out.println("User found: " + emailId);
            } else {
                System.out.println("User not found: " + emailId);
            }

        } catch (SQLException e) {
            status = "Error: " + e.getMessage();
            e.printStackTrace();
        } finally {
            DBUtil.closeConnection(con);
            DBUtil.closeConnection(stmt);
            DBUtil.closeConnection(rs);
        }
        return status;
    }
}
