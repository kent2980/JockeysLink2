package com.servlet;

import java.io.IOException;
import java.util.ArrayList;
import java.util.stream.Collectors;

import javax.servlet.RequestDispatcher;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import com.pckeiba.schedule.SelectYearSchedule;

@WebServlet("/kaisaichedule")
public class KaisaiScheduleServlet extends HttpServlet {

	/**
	 *
	 */
	private static final long serialVersionUID = 1L;

	private SelectYearSchedule schedule;

	public KaisaiScheduleServlet() {
		schedule = new SelectYearSchedule();
	}
	@Override
	protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {

		//URLパラメータからレースコードを取得する
		int requestPara = Integer.valueOf(req.getParameter("year"));
		schedule.setYear(requestPara);
		new ArrayList<String>().stream().collect(Collectors.toList());
		//各レース詳細オブジェクトを取得する
		req.setAttribute("schedule", schedule);
		//各レース詳細オブジェクトをフォワードする
		RequestDispatcher di = req.getRequestDispatcher("/WEB-INF/jsp/kaisaischedule.jsp");
		di.forward(req, resp);

	}

}
