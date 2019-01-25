package com.servlet;

import java.io.IOException;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;

import javax.servlet.RequestDispatcher;
import javax.servlet.ServletConfig;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import com.pckeiba.schedule.ImmediatelyAfterRace;
import com.pckeiba.schedule.RaceListLoad;

@WebServlet("/index")
public class IndexServlet extends HttpServlet {
	/**
	 *
	 */
	private static final long serialVersionUID = 1L;

	/**　
	 * フィールド
	 */
	private ImmediatelyAfterRace afterRace;
	private RaceListLoad raceListLoader;

	@Override
	protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {

		//リクエストパラメータがあればそちらを検索する
		String kaisai = req.getParameter("kaisai");
		LocalDate date;
		try {
			date = LocalDate.parse(kaisai, DateTimeFormatter.ofPattern("yyyy-MM-dd"));
		}catch(NullPointerException e) {
			date = LocalDate.now();
		}

		//最も近いレース開催日を検索する
		afterRace.setDate(date);
		LocalDate kaisaiDate = afterRace.getKaisaiNenGappi();

		//レースリストを取得する
		raceListLoader.setDate(kaisaiDate);

		//フォワード
		req.setAttribute("loader", raceListLoader);
		RequestDispatcher rd = req.getRequestDispatcher("/WEB-INF/jsp/index.jsp");
		rd.forward(req, resp);
	}

	@Override
	protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
		super.doPost(req, resp);
	}

	@Override
	public void destroy() {
		super.destroy();
	}

	@Override
	public void init(ServletConfig config) throws ServletException {
		super.init(config);
		afterRace = new ImmediatelyAfterRace();
		raceListLoader = new RaceListLoad();
	}


}
