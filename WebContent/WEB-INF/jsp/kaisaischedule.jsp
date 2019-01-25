<%@ page
	language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"

    import="com.pckeiba.schedule.*"
    import="java.util.*"
    import="java.time.LocalDate"
    import="java.time.format.DateTimeFormatter"
%>
<%
SelectYearSchedule schedule = (SelectYearSchedule)request.getAttribute("schedule");
%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<link href="../css/StyleDanceTable.css" rel="stylesheet">
<link href="/JockeysLink/css/StyleDanceTable.css" rel="stylesheet">
<link rel="shortcut icon" href="/JockeysLink/icon/kyosoba_3.ico">
<title>Jockey's Link</title>
</head>
<body>

<nav>
	<ui>
		<li><a href="/JockeysLink/index">HOME</a></li>
		<li><a href="#">本日のレース</a></li>
		<li><a href="/JockeysLink/kaisaichedule?year=<% out.println(LocalDate.now().getYear()); %>">開催スケジュール</a></li>
		<li><a href="#">データベース</a></li>
		<li class="map"><a href="#">サイトマップ</a></li>
	</ui>
</nav>

<div id="kaisaiSchedule">
<%
	//本日までのレースのみを抽出します
	List<KaisaiScheduleSet> scheduleList = schedule.getScheduleList(LocalDate.now().plusDays(4));
	//開催スケジュールを表示します
	LocalDate date = LocalDate.of(1900, 1, 1);
	for(KaisaiScheduleSet s : scheduleList){
		//開催年月日が異なる場合は・・・
		if(!s.getKaisaiNengappi().isEqual(date)){
			if(!date.isEqual(LocalDate.of(1900, 1, 1))){
				out.println("</span>");
				out.println("</span>");
				out.println("</div>");
			}
			%>

			<!-- **********************************************************************************************
			****************** ここから<% out.print(s.getKaisaiNengappi()); %>の記述をはじめます ***************************************
			*************************************************************************************************** -->

			<%
			date = s.getKaisaiNengappi();
			out.print("<div class=\"nengappi\">");
			switch(s.getYobi()){
			case "土":
				out.println("<span class=\"maru normal blue\">");
				break;
			case "日":
				out.println("<span class=\"maru normal red\">");
				break;
			case "祝":
				out.println("<span class=\"maru normal green\">");
				break;
			default:
				out.println("<span class=\"maru normal yellow\">");
			}
			%>

			<a class="letter3" href="/JockeysLink/index?kaisai=<% out.print(s.getKaisaiNengappi()); %>"><% out.print(s.getKaisaiNengappi().format(DateTimeFormatter.ofPattern("MM/dd")) + "<br>（" + s.getYobi() + "）"); %></a>
			</span>

			<span class="kaisaikeibajo shikaku white">
        	<span class="kaisaikeibajo moji">
			<%
		}
		%>
		<span class="jodata">
		<span class="keibajo"><% out.print(s.getKeibajo()); %>競馬場</span>
		<%
		if(s.getJusho1().getTokubetsuKyosoBango() != 0){
		%>
		<span class="kyosoTitle"><a href="/JockeysLink/DanceTableGraph?racecode=<% out.print(s.getJusho1().getRaceCode()); %>&mode=dance"><% out.print(s.getJusho1().getKyosomeiRyakusho_6()); %></a></span>
		<div class="jushodata kyori small"><% out.print(s.getJusho1().getKyori()>0?s.getJusho1().getKyori() + "m":""); %></div>
		<span class="jushodata track small"><% out.print(s.getJusho1().getJushoTrack()); %></span>
		<span class="jushodata juryoshubetsu small"><% out.print(s.getJusho1().getJuryoShubetsu()); %></span>
		<span class="jushodata kyososhubetsu small"><% out.print(s.getJusho1().getKyosoShubetsu()); %></span>
		<span class="jushodata grade small"><% out.print(s.getJusho1().getJushoGrade()); %></span>
		</span>
		<%
		}else{
		%>
		<span class="kyosoTitle"><a href="/JockeysLink/DanceTableGraph?racecode=<% out.print(s.getMainKyoso().getRaceCode()); %>&mode=dance"><% out.print(s.getMainKyoso().getKyosomeiRyakusho_6()); %></a></span>
		<div class="jushodata kyori small"><% out.print(s.getMainKyoso().getKyori()>0?s.getMainKyoso().getKyori() + "m":""); %></div>
		<span class="jushodata track small"><% out.print(s.getMainKyoso().getJushoTrack()); %></span>
		<span class="jushodata juryoshubetsu small"><% out.print(s.getMainKyoso().getJuryoShubetsu()); %></span>
		<span class="jushodata kyososhubetsu small"><% out.print(s.getMainKyoso().getKyosoShubetsu()); %></span>
		<span class="jushodata grade small"><% out.print(s.getMainKyoso().getJushoGrade()); %></span>
		</span>
		<%
		}
	}
	out.println("</span>");
	out.println("</span>");
	out.println("<div>");
%>
</div>
</body>
</html>