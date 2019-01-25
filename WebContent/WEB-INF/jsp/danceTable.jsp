<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page import="com.pckeiba.racedata.RaceDataSet"
         import="com.pckeiba.umagoto.UmagotoDataSet"
         import="com.pckeiba.umagoto.UmagotoDrunSet"
         import="com.pckeiba.analysis.UmagotoAnalysis"
         import="java.util.List"
         import="java.util.Map"
         import="java.io.PrintWriter"
         import="com.util.UtilClass"
         import="java.math.BigDecimal"
         import="java.lang.IndexOutOfBoundsException"
   		 import="java.time.LocalDate"
%>
<%
RaceDataSet raceData = (RaceDataSet) request.getAttribute("raceData");
List<UmagotoDataSet> umaList1 = UtilClass.AutoCast(request.getAttribute("umaList"));
List<Map<String,UmagotoDataSet>> map = UtilClass.AutoCast(request.getAttribute("umaMap"));
Map<String,UmagotoDrunSet> drunList = UtilClass.AutoCast(request.getAttribute("drunList"));
UmagotoAnalysis analysis = (UmagotoAnalysis) request.getAttribute("analysis");
PrintWriter pw = response.getWriter();
String kyosoTitle = raceData.getKyosomeiHondai().length()>0
				?raceData.getKyosomeiHondai()
				:raceData.getKyosoShubetsu().substring(raceData.getKyosoShubetsu().indexOf("系")+1, raceData.getKyosoShubetsu().length()) + raceData.getKyosoJoken();

%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<link rel="stylesheet" href="https://use.fontawesome.com/releases/v5.0.10/css/all.css" integrity="sha384-+d0P83n9kaQMCwj8F4RJB66tzIwOKmrdb46+porD/OvrJ+37WqIM7UoBtwHO6Nlg" crossorigin="anonymous">
<link href="https://fonts.googleapis.com/earlyaccess/roundedmplus1c.css" rel="stylesheet" />
<link href="../css/StyleDanceTable.css" rel="stylesheet">
<link href="/JockeysLink/css/StyleDanceTable.css" rel="stylesheet">
<link rel="shortcut icon" href="/JockeysLink/icon/kyosoba_3.ico">
<title><%= raceData.getKaisaiNenGappi() + " " + kyosoTitle %></title>
</head>
<body id="raceData">

<nav>
	<ui>
		<li><a href="/JockeysLink/index">HOME</a></li>
		<li><a href="#">本日のレース</a></li>
		<li><a href="/JockeysLink/kaisaichedule?year=<% out.println(LocalDate.now().getYear()); %>">開催スケジュール</a></li>
		<li><a href="#">データベース</a></li>
		<li class="map"><a href="#">サイトマップ</a></li>
	</ui>
</nav>

<div class="raceinfo">
<!-- ***********************【開催年月日・開催回次・競馬場・開催日次・レース番号】**********************************-->

<div class="kaisaiJoho">
	<%
	out.println(raceData.getKaisaiNenGappi());
	out.println(raceData.getKaisaiKaiji() + raceData.getKeibajo() + raceData.getKaisaiNichiji());
	out.println(raceData.getRaceBango() + "R");
	%>
</div>
<p>

<!-- ***********************【競争名・グレード】**********************************-->
<div class="kyosoTitle">
	<%
	out.println(raceData.getJushoKaiji()>0?"第" + raceData.getJushoKaiji() + "回":"");
	%>
	<span class="kyosoName">
	<%
	out.println(kyosoTitle);
	out.println(raceData.getGrade().equals("特別競走")?"":raceData.getGrade());
	%>
	</span>
</div>
<p>

<!-- ***********************【競争条件・競争記号・重量種別】**********************************-->

<div>
<span class="kyosoShubetsu">
	<%
	out.println(raceData.getKyosoJoken());
	out.println(raceData.getKyosoShubetsu());
	out.println(raceData.getKyosoKigo());
	out.println(raceData.getJuryoShubetsu());
	out.println(raceData.getTorokuTosu() + "頭");
	%>
</span>

<!-- ***********************【距離・トラック・発送時刻・天候・馬場状態】**********************************-->

<span class="kyosoJoho">
	<%
	out.println(raceData.getKyori() + "m");
	out.println(raceData.getTrackCode());
	out.println(raceData.getHassoJikoku());
	out.println(raceData.getTenko());
	out.println(raceData.getShibaJotai().length()>0?raceData.getShibaJotai():raceData.getDirtJotai());
	out.println("RPCI：" + raceData.getRPCI());
	out.println("AVE3F：" + raceData.getAve3f());
	out.println("RS：" + raceData.getSrunRow());
	%>
</span>
</div>
<p>

<!-- *************************************************************************************
     ****************************ここから出馬表のテーブルを記述する********************************
     ************************************************************************************* -->
</div>

<table class="umaData">

<!-- *************【ヘッダー】************** -->
	<tr>
	<th class="wakuban">枠番</th>
	<th class="umaban">馬番</th>
	<th class="bameiCell">馬名</th>
	<th class="kakoso">前走</th>
	<%
	for(int i=2;i<=map.size();i++){
		out.println("<th class=\"kakoso\">" + i + "走前</th>");
	}
	%>
	</tr>

<!-- **************【データ部】************* -->
	<%
	for(int i = 0; i < umaList1.size(); i++){
		int umaban = i + 1;
		UmagotoDataSet uma1 = umaList1.get(i);

		try{
		if(!raceData.getDataKubun().equals(uma1.getDataKubun()) && uma1.getDataKubun().equals("1"))
		throw new IllegalArgumentException();

		//出走データ
		out.println("<tr>");
		out.println(uma1.getDataKubun().equals("1")?"<td></td>":"<td class=\"bango wakuColor" + uma1.getWakuban() + "\">" + uma1.getWakuban() + "</td>");
		out.println(uma1.getDataKubun().equals("1")?"<td></td>":"<td class=\"bango\">" + uma1.getUmaban() + "</td>");
		out.println("<td class=\"bamei\">");
		out.println("<div>");
		out.println("<span class=\"name\">" + uma1.getBamei() + "</span>");
		out.println("<span class=\"chakujun\">");
		out.println(uma1.getKakuteiChakujun()>0?uma1.getKakuteiChakujun() + "着":"");
		out.println("</span><br>");
		out.println("SRUN：" + uma1.getSrun());
		out.println(uma1.getKyakushitsu());
		out.println("<br>");
		out.println("　父： " + uma1.getFather());
		out.println("<br>");
		out.println("母父： " + uma1.getGrandfather());
		//<Drun>取得不可の例外処理
		try{
			//取得した値がnullならば例外発生！
			drunList.get(uma1.getKettoTorokuBango()).getDrun().add(BigDecimal.ONE);
			out.println("<div class=\"drun\">");
			out.println(drunList.get(uma1.getKettoTorokuBango()).getDrun() + " pt_");
			out.println(drunList.get(uma1.getKettoTorokuBango()).getDrunRunk());
			out.println(drunList.get(uma1.getKettoTorokuBango()).getBunsan());
			out.println("</div>");
		}catch(NullPointerException e){
			e.getStackTrace();
			out.println("計測不能");
		}
		out.println("<br>");
		out.println(uma1.getTozaiShozoku());
		out.println(uma1.getChokyoshi().replace("　", ""));
		//<馬体重>取得不可の例外処理
		try{
			out.println(uma1.getZogensa().length()>0?uma1.getBataiju() + "kg(" + uma1.getZogensa() + ")":"");
		}catch(NullPointerException e){
			e.getStackTrace();
		}finally{
			out.println("<br>");
		}
		//<単勝人気>取得不可の例外処理
		try{
			out.println(uma1.getTanshoNinkijun() + "人気");
			out.println(uma1.getTanshoOdds());
		}finally{
			out.println(uma1.getSeibetsu() + uma1.getBarei());
			out.println(uma1.getFutanJuryo() + "kg");
			out.println(uma1.getKishumei().replace("　", ""));
			try{
				out.println("<br>");
				analysis.getDistanceAnalisis(1);	//インデックスが存在しない場合は例外をスローします
				out.println("<div class=\"analysis\">");
				out.println("距離 :");
				out.println(analysis.getDistanceAnalisis(umaban));
				out.println("間隔 :");
				out.println(analysis.getRaceInterval(umaban));
				out.println("</div>");
			}catch(IndexOutOfBoundsException e){
				out.println("適正データをダウンロードできません");
			}
			out.println("</div>");
			out.println("</td>");
		}

		/***************************************************************************************************
		****************************************************************************************************
		*******************************************<<過去走データ*>>*******************************************
		****************************************************************************************************
		****************************************************************************************************/

		//初出走時の例外処理
		try{
		for(int t = 0; t<map.size();t++){
			UmagotoDataSet uma = map.get(t).get(uma1.getKettoTorokuBango());
			if(t==0){
				uma.toString();	//nullの場合は"初出走"
			}
			out.println("<td class=\"kakoso\">");
			//t回前の過去走が存在しないときの例外処理
			try{
				String kakoKyosoTitle = uma.getKyosomeiRyakusho6().length()>0
										?uma.getKyosomeiRyakusho6()
										:uma.getKyosoShubetsu().substring(uma.getKyosoShubetsu().indexOf("系")+1, uma.getKyosoShubetsu().length()) + uma.getKyosoJoken();
				out.println("<span class=\"chakujun\">" + uma.getKakuteiChakujun() + "着</span>");
				out.println(uma.getKaisaiKaiji() + uma.getKeibajo() + uma.getKaisaiNichiji());
				out.println(uma.getKaisaiNenGappi());
				out.println(uma.getBaba().equals("ダート")?"ダ":"芝");
				out.println(uma.getKyori() + "m");
				out.println("<br>");
				String grade = uma.getGrade().length()==0?uma.getKyosoJoken():uma.getGrade().equals("特別競走")?uma.getKyosoJoken():uma.getGrade();
				out.println("<a href=\"/JockeysLink/Race?racecode=" + uma.getRaceCode() + "\">" + kakoKyosoTitle + "</a>");
				out.println(uma.getKeibajo());
				out.println(uma.getTenko());
				out.println(uma.getShibaBabaJotai().length()>0?uma.getShibaBabaJotai():uma.getDirtBabaJotai());
				out.println(uma.getJuryoShubetsu());
				out.println("<br>");
				out.println("RP：" + uma.getRPCI());
				out.println("FP：" + uma.getfPCI());
				out.println(uma.getSrun55().doubleValue()>0 ? "RS：" + uma.getSrun55() + "／" + uma.getRaceSrun() : "RS：<span class=\"srunSmall\">" + uma.getSrun55() + "／" + uma.getRaceSrun() + "</span>");
				out.println("<br>");
				out.println(uma.getCorner1Juni() + "-" + uma.getCorner2Juni() + "-" + uma.getCorner3Juni() + "-" + uma.getCorner4Juni());
				out.println(uma.getKyakushitsu());
				out.println(uma.getShussoTosu() + "頭" + uma.getUmaban() + "番" + uma.getTanshoNinkijun() + "人");
				out.println("<span class=\"srun\">");
				//Srunが取得できないときの例外処理
				try{
					out.println(uma.getSrun().doubleValue()>0?uma.getSrun().toString() + " pt":"<span class=\"srunSmall\">" + uma.getSrun() + " pt</span>");
				}catch(NullPointerException e){
					out.println("計測不能");
				}
				out.println("</span>");
				out.println("<br>");
				out.println(uma.getSohaTimeValue());
				out.println(uma.getAve3f() + "-" + uma.getKohan3F());
				out.println(uma.getBataiju() + "kg(" + uma.getZogensa() + ")");
				out.println("<br>");
				out.println(uma.getKishumeiRyakusho());
				out.println(uma.getFutanJuryo());
				out.println(uma.getAiteBamei1() + "(" + uma.getTimeSa() + ")");
			}catch(NullPointerException e){
				e.getStackTrace();
				out.println("<span class=\"kakosoError\"><div>未出走</div></span>");
			}finally{
				out.println("</td>");
			}
		}
	}catch(NullPointerException e){
		e.getStackTrace();
		out.println("<td colspan=\"4\"><span class=\"kakosoError\"><div>初出走</div></span></td>");
	}
		//ここまで
		out.println("</tr>");
	}catch(IllegalArgumentException | NullPointerException e){
		e.printStackTrace();
	}
	}
	%>
</table>

<!-- *****************************************************************************************
     ********************************出馬表テーブル ここまで*****************************************
     ***************************************************************************************** -->

</body>
</html>