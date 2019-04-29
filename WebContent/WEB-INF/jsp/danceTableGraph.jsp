<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ page import="com.pckeiba.racedata.RaceDataSet"
	import="com.pckeiba.racedata.RaceDataLoad"
	import="com.pckeiba.umagoto.UmagotoDataSet"
	import="com.pckeiba.umagoto.UmagotoDrunSet"
	import="com.pckeiba.umagoto.UmagotoDataLoad"
	import="com.pckeiba.umagoto.UmagotoDataIndexLoad"
	import="com.pckeiba.umagoto.UmagotoDataIndexSet"
	import="com.pckeiba.analysis.UmagotoAnalysis"
	import="com.pckeiba.schedule.RaceListLoad"
	import="com.pckeiba.racedata.RaceDataDefault"
	import="com.pckeiba.list.LapList" import="java.util.List"
	import="java.util.Map" import="java.io.PrintWriter"
	import="com.util.UtilClass" import="java.math.BigDecimal"
	import="java.lang.IndexOutOfBoundsException"
	import="java.time.LocalDate" import="java.util.Date"
	import="java.text.SimpleDateFormat" import="java.util.HashMap"
	import="java.util.ArrayList" import="java.time.LocalDate"
	import="java.time.LocalDateTime"
	import="java.time.format.DateTimeFormatter"
	import="com.example.entity.ViewRaceShosai"
	import="com.example.entity.ViewRaceShosaiExample"
	import="com.example.entity.ViewRaceShosaiMapper"
	import="com.view.racedata.RaceShosaiReader"
	import="java.util.stream.Collectors"
	import="java.util.Collections"
	import="java.util.Comparator"
	import="java.util.NoSuchElementException"
	import="com.details.UmaNowChakujunBetsu"
	import="java.util.Set"
	import="java.util.TreeSet"
	import="com.collections.ChakuBetsuTreeSet"
	import="com.pckeiba.analysis.HomestretchAnalysis"
	%>
<%
	RaceDataSet raceData = (RaceDataSet) request.getAttribute("raceData");
	List<UmagotoDataSet> umaNowData = UtilClass.AutoCast(request.getAttribute("umaList"));
	List<Map<String, UmagotoDataSet>> umaKakoData = UtilClass.AutoCast(request.getAttribute("umaMap"));
	List<UmagotoDrunSet> drunList = UtilClass.AutoCast(request.getAttribute("drunList"));
	UmagotoDataIndexLoad indexLoad = UtilClass.AutoCast(request.getAttribute("index"));
	List<UmagotoDataIndexSet> indexList = indexLoad.getIndexList();
	UmagotoAnalysis analysis = (UmagotoAnalysis) request.getAttribute("analysis");
	RaceListLoad raceList = UtilClass.AutoCast(request.getAttribute("raceList"));
	UmagotoDataLoad umaLoad = UtilClass.AutoCast(request.getAttribute("umaLoad"));
	PrintWriter pw = response.getWriter();
	String kyosoTitle = raceData.getKyosomeiHondai().length() > 0
			? raceData.getKyosomeiRyaku10()
			: raceData.getKyosoShubetsu().substring(raceData.getKyosoShubetsu().indexOf("系") + 1,
					raceData.getKyosoShubetsu().length()) + raceData.getKyosoJoken();

	/************************<変数の説明>****************************
	* raceData = 指定したレースコードのレースデータを取得します
	* umaNowData = 指定したレースコードの馬毎データを取得します
	* umaKakoData = 過去走の馬毎データを取得します
	* drunList = 馬毎のDRunを取得します
	***************************************************************/
	String netkeibaRaceCode = raceData.getRaceCode().substring(0, 4) + raceData.getRaceCode().substring(8, 16);
	String netkeiba = "http://race.netkeiba.com/?pid=race&id=c" + netkeibaRaceCode + "&mode=result";
	String netkeibaOdds = "https://ipat.netkeiba.com/?pid=ipat_input&rid=" + netkeibaRaceCode;
	String netkeibaHorse = "https://db.netkeiba.com/horse/"; //-> 血統登録番号で指定する
	String jrdbUmaData = "http://wdb.jrdb.com/awahana/ijrdv/ijvu.php?kettonum="; //8桁の血統登録番号で指定する

	/************************<データの整形を行います>****************************
	* １．2走前から4走前までのSRunの平均を求めます
	***************************************************************/
	class UmaSrunUpper {
		String kettoTorokuBango;
		boolean hantei;
		int ninki;
		BigDecimal srunAve;
		public UmaSrunUpper(String kettoTorokuBango, boolean hantei, int ninki, BigDecimal srunAve) {
			this.kettoTorokuBango = kettoTorokuBango;
			this.hantei = hantei;
			this.ninki = ninki;
			this.srunAve = srunAve;
		}

		public String getKettoTorokuBango() {
			return kettoTorokuBango;
		}
		public boolean getHantei() {
			return hantei;
		}
		public int getNinki() {
			return ninki;
		}
		public BigDecimal getSrunAve() {
			return srunAve;
		}
	}
	Map<String, Boolean> srunMapper = new HashMap<>();
	List<UmaSrunUpper> upperList = new ArrayList<>();
	String popularUpper = "";
	int ninkiMin = 0;
	for (UmagotoDataSet nowData : umaNowData) {
		String kettoTorokuBango = nowData.getKettoTorokuBango();
		try {
			BigDecimal allSrunAve = umaLoad.getAverageSrun(kettoTorokuBango, 2, 3, 4, 5);
			BigDecimal aveSrun = umaLoad.getAverageSrun(kettoTorokuBango, 3, 4, 5);
			BigDecimal zenso = umaKakoData.get(0).get(kettoTorokuBango).getSrun();
			BigDecimal zenzenso = umaKakoData.get(1).get(kettoTorokuBango).getSrun();
			boolean hantei = zenso.compareTo(aveSrun) > 0;
			if (hantei == true)
				hantei = zenso.compareTo(zenzenso) > 0;
			srunMapper.put(kettoTorokuBango, hantei);
			UmaSrunUpper upper = new UmaSrunUpper(kettoTorokuBango, hantei, nowData.getTanshoNinkijun(),
					allSrunAve);
			upperList.add(upper);
		} catch (NullPointerException e) {
			srunMapper.put(kettoTorokuBango, false);
		}
	}
	try{
		ninkiMin = upperList.stream()
				.filter(s -> s.getNinki() > 0)
				.filter(s -> s.getHantei() == true)
				.mapToInt(s -> s.getNinki())
				.min()
				.getAsInt();
	}catch(NoSuchElementException e){
	}
	for(UmaSrunUpper upper: upperList){
		if(upper.getNinki() == ninkiMin & upper.getNinki() != 0){
			popularUpper = upper.getKettoTorokuBango();
		}
	}

%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<link href="https://fonts.googleapis.com/earlyaccess/roundedmplus1c.css"
	rel="stylesheet" />
<link href="../css/danceTableGraph.css" rel="stylesheet">
<link href="/JockeysLink/css/danceTableGraph.css" rel="stylesheet">
<link rel="shortcut icon" href="/JockeysLink/icon/kyosoba_3.ico">
<script type="text/javascript"
	src="https://ajax.googleapis.com/ajax/libs/jquery/1.9.1/jquery.min.js"></script>
<script type="text/javascript" src="../js/pop.js"></script>
<script type="text/javascript" src="/JockeysLink/js/pop.js"></script>
<title>
	<%
		out.print(kyosoTitle);
	%>
</title>
</head>
<body id="dance">

	<!-- *****************************************************************************************
     *****************************************************************************************
     							レースデータを記述します
     *****************************************************************************************
     ***************************************************************************************** -->
	<div id="title">
		<%
			int year = LocalDate.now().getYear();
		%>
		<a href="/JockeysLink/kaisaichedule?year=<%out.print(year);%>">
			<div id="logo">
				<!-- <img src="../picture/logo.jpg" alt="トップページへのリンク" class="logo"> -->
				<img src="/JockeysLink/picture/logo.jpg" alt="トップページへのリンク"
					class="logo"> <span class="title">Jockeys->Link</span>
			</div>
		</a>
		<div id="roundData">
			<span class="kaisai">
				<%
					out.print(raceData.getKaisaiNenGappi() + "（" + raceData.getYobi() + "）");
				%>
			</span> <span class="keibajo">
				<%
					out.print(raceData.getKeibajo());
				%>
			</span> <span class="round">
				<%
					out.print(raceData.getRaceBango() + "R");
				%>
			</span>
		</div>
		<div id="kyosomei">
			<%
				String jushoKaiji = raceData.getJushoKaijiCode() == 0 ? "" : "第" + raceData.getJushoKaiji() + "回";
			%>
			<span class="kaiji">
				<%
					out.print(jushoKaiji);
				%>
			</span> <span class="kyosomei">
				<%
					out.print(kyosoTitle);
				%>
			</span>
		</div>
		<div id="raceData">
			<div class="raceSelect">
				<form name="fm">
					<select name="s" class="raceSelect" onchange="urlJump()">
						<option value="" hidden disabled selected></option>
						<%
							List<RaceDataDefault> raceDataList = raceList.getRaceList();
							for (int i = 0; i < raceDataList.size(); i++) {
								RaceDataDefault race = raceDataList.get(i);
								boolean raceCodeEquals = raceData.getRaceCode().equals(race.getRaceCode());
								String kyosomei = race.getKyosomeiHondai().length() > 0
										? race.getKyosomeiRyaku10()
										: race.getKyosoShubetsu().substring(race.getKyosoShubetsu().indexOf("系") + 1,
												race.getKyosoShubetsu().length()) + race.getKyosoJoken();
								String selectKyosomei = race.getKeibajo() + " - " + String.format("%02d", race.getRaceBango()) + "R　"
										+ kyosomei;
						%>
						<option <%out.print(raceCodeEquals == true ? " selected" : "");%>
							value="/JockeysLink/DanceTableGraph?racecode=<%out.print(race.getRaceCode());%>&mode=dance">
							<%
								out.print(selectKyosomei);
							%>
						</option>
						<%
							}
						%>
					</select>
				</form>
			</div>
			<div id="data">
				<div class="courseData desctop">
					<span>
						<%
							out.print("RPCI:" + raceData.getRPCI());
						%>
					</span>
					-
					<span>
						<%
							out.print(raceData.getKyori() + "m");
						%>
					</span>
					-
					<span>
						<%
							out.print(raceData.getTrackCode());
						%>
					</span>
					-
					<span>
						<%
							out.print(raceData.getHassoJikoku());
						%>
					</span>
				</div>
				<div class="raceData desctop">
					<span>
						<%
							out.println(raceData.getKyosoJoken());
						%>
					</span> <span>
						<%
							out.println(raceData.getKyosoShubetsu());
						%>
					</span> <span>
						<%
							out.println(raceData.getKyosoKigo());
						%>
					</span> <span>
						<%
							out.print(raceData.getJuryoShubetsu());
						%>
					</span> <span>
						<%
							out.print(raceData.getTorokuTosu() + "頭");
						%>
					</span>
					<!--  <span>＜<%//out.print(indexLoad.getDrunMargin(1) + "pt");%>＞</span> -->
				</div>
			</div>
		</div>
		<div id="menu">
			<div>
				<span class="navi">分析</span>
			</div>
			<div>
				<a href="<%out.print(netkeibaOdds);%>" target="_blank"
					class="navi">IPAT</a>
			</div>
			<div>
				<a
					href="/JockeysLink/DanceTableGraph?racecode=<%out.print(raceData.getRaceCode());%>&mode=result"
					class="navi">結果</a>
			</div>
		</div>
	</div>

	<!-- URLジャンプのJavaScript -->
	<script type="text/javascript">
		function urlJump() {
			var browser = document.fm.s.value;
			location.href = browser;
		}
	</script>
	<!-- *****************************************************************************************
     ********************************ここからグラフを記述する*****************************************
     ***************************************************************************************** -->

	<!-- ①チャート描画先を設置 -->
	<%
		int tosu = raceData.getShussoTosu();
		int height = tosu < 15 ? 30 : 35;
	%>
	<div id="timeChart" class="Chart"width:"100%">
		<h2 class=title>タイムランク</h2>
		<canvas id="myChart" width="100" height="<%out.print(height);%>"></canvas>
	</div>

	<!-- ②Chart.jsの読み込み -->
	<script
		src="https://cdnjs.cloudflare.com/ajax/libs/Chart.js/2.7.2/Chart.bundle.min.js"></script>

	<!-- ③チャート描画情報の作成 -->
	<script>
		window.onload = function() {
			ctx = document.getElementById("myChart").getContext("2d");
			window.myBar = new Chart(ctx, {
				type : 'bar',
				data : barChartData,
				options : complexChartOption
			});
		};
	</script>

	<!-- ④チャートデータの作成 -->
	<script>
		var barChartData = {
			labels : [
	<%for (int i = 0; i < indexList.size(); i++) {
				UmagotoDataIndexSet uma1 = indexList.get(i);
				int umaban = uma1.getUmaban() == 0 ? i + 1 : uma1.getUmaban();
				String kettoBango = indexList.get(i).getKettoTorokuBango();
				UmagotoDataSet zenso = umaKakoData.get(0).get(kettoBango);
				//開催年月日をフォーマットする
				String kaisaiNenGappi;
				try {
					kaisaiNenGappi = zenso.getKaisaiNenGappi();
					DateTimeFormatter dtf1 = DateTimeFormatter.ofPattern("yyyy年MM月dd日");
					DateTimeFormatter dtf2 = DateTimeFormatter.ofPattern("y／M／d");
					LocalDate ld = LocalDate.parse(kaisaiNenGappi, dtf1);
					kaisaiNenGappi = dtf2.format(ld);
				} catch (NullPointerException e) {
					kaisaiNenGappi = "初出走";
				}
				//ラベルを出力します
				out.print("[\"" + umaban + ". " + uma1.getBamei() + " / " + uma1.getTanshoNinkijun() + "人気\", \"（前走："
						+ kaisaiNenGappi + "）\"]");
				if (i + 1 < indexList.size()) {
					out.print(",");
				}
			}%>
		],
			datasets : [
					{
						type : 'bar',
						label : 'タイムランク',
						data : [
	<%for (int i = 0; i < indexList.size(); i++) {
				UmagotoDataIndexSet uma1 = indexList.get(i);
				out.print(uma1.getDrun());
				if (i + 1 < indexList.size()) {
					out.print(",");
				}
			}%>
		],
						backgroundColor : [
	<%String escape = "'rgba(255, 57, 59, 0.8)'";
			String preceding = "'rgba(255, 140, 60, 0.8)'";
			String insert = "'rgba(246, 255, 69, 0.8)'";
			String last = "'rgba(57, 157, 255, 0.8)'";
			String defaultColor = "'rgba(184, 184, 184, 0.8)'";
			for (int i = 0; i < indexList.size(); i++) {
				String kettoTorokuBango = indexList.get(i).getKettoTorokuBango();
				int kyakushitsu = analysis.getPredictionKyakushitsuHantei(kettoTorokuBango);
				switch (kyakushitsu) {
					case 1 :
						out.print(escape);
						break;
					case 2 :
						out.print(preceding);
						break;
					case 3 :
						out.print(insert);
						break;
					case 4 :
						out.print(last);
						break;
					default :
						out.print(defaultColor);
				}
				if (i + 1 < indexList.size()) {
					out.print(",");
				}
			}%>
		],
						borderWidth : 1
					},
					{
						type : 'line',
						label : 'トップスピード',
						data : [
	<%for (int i = 0; i < indexList.size(); i++) {
				UmagotoDataIndexSet uma1 = indexList.get(i);
				out.print(uma1.getSpeedRate());
				if (i + 1 < indexList.size()) {
					out.print(",");
				}
			}%>
		],
						borderColor : 'rgba(54,164,235)',
						backgroundColor : 'rgba(54,164,235,0.5)'
					},
					{
						type : 'line',
						label : '1走前タイムランク',
						data : [
	<%for (int i = 0; i < indexList.size(); i++) {
				String kettoBango = indexList.get(i).getKettoTorokuBango();
				UmagotoDataSet uma1 = umaKakoData.get(0).get(kettoBango);
				try {
					BigDecimal srun = (uma1.getSrun().add(BigDecimal.valueOf(12))).multiply(BigDecimal.valueOf(4.5))
							.setScale(2, BigDecimal.ROUND_HALF_UP);
					out.print(srun);
				} catch (NullPointerException e) {
					out.print("0");
				}
				if (i + 1 < indexList.size()) {
					out.print(",");
				}
			}%>
		],
						borderColor : 'rgba(254,164,65)',
						backgroundColor : 'rgba(254,164,65,0.1)'
					},
					{
						type : 'line',
						label : '1走前RPCI',
						data : [
	<%for (int i = 0; i < indexList.size(); i++) {
				String kettoBango = indexList.get(i).getKettoTorokuBango();
				UmagotoDataSet uma1 = umaKakoData.get(0).get(kettoBango);
				try {
					BigDecimal rpci = uma1.getRPCI();
					out.print(rpci);
				} catch (NullPointerException e) {
					out.print("0");
				}
				if (i + 1 < indexList.size()) {
					out.print(",");
				}
			}%>
		],
						borderColor : 'rgb(221, 226, 15)',
						backgroundColor : 'rgba(241, 252, 27,0.1)'
					} ],
		};
	</script>

	<!-- ⑤オプションの作成 -->
	<%
		int minDrun = indexList.stream().filter(s -> s.getDrun() != null)
				.mapToInt(s -> s.getDrun().setScale(-1, BigDecimal.ROUND_DOWN).intValue()).min().getAsInt();
		int minSpeedRate = indexList.stream().filter(s -> s.getSpeedRate() != null)
				.mapToInt(s -> s.getSpeedRate().setScale(-1, BigDecimal.ROUND_DOWN).intValue()).min().getAsInt();
		int minYscale = minDrun < minSpeedRate ? minDrun : minSpeedRate;
	%>
	<script>
		var complexChartOption = {
			tooltips : {},
			responsive : true,
			scales : {
				xAxes : [ {
					ticks : {
						autoSkip : false,
						fontSize : 12,
						minRotation : 20
					},
				} ],
				yAxes : [ {
					ticks : {
						beginAtZero : true,
						min : 30,
						max : 70,
						fontSize : 13.5
					},
				} ],
			}
		};
	</script>

	<!-- *****************************************************************************************
     **********************************グラフ記述ここまで*******************************************
     ***************************************************************************************** -->

<%
	int dataKubun;
	try{
		dataKubun = Integer.valueOf(raceData.getDataKubun());
	}catch(NumberFormatException e){
		dataKubun = 0;
	}
	if(dataKubun > 2){
%>
	<div class="datails">
		<h1>Racing Result Details</h1>
		<p>このレース結果の詳細からデータによる分析をおこなっていきましょう</p>
		<h2>着順から</h2>
			<%
				//変数を宣言します
				ChakuBetsuTreeSet chakuBetsuList = new ChakuBetsuTreeSet();
				//今走の出馬表からループを開始します
				for(UmagotoDataSet dataSet: umaNowData){
					String kettoTorokuBango = dataSet.getKettoTorokuBango();	//血統登録番号
					int kakuteiChakujun = dataSet.getKakuteiChakujun();		//確定着順
					UmaNowChakujunBetsu chakuBetsu = new UmaNowChakujunBetsu(kettoTorokuBango, kakuteiChakujun);	//着順ごとのデータを収納する
					chakuBetsu.setKakoKyakushitsu(analysis.getPredictionKyakushitsu(kettoTorokuBango));		//過去脚質
					chakuBetsu.SetNinki(dataSet.getTanshoNinkijun());	//単勝人気
					chakuBetsu.setUmaban(dataSet.getUmaban());		//馬番
					chakuBetsu.setNowKyakushitsu(dataSet.getKyakushitsu());		//今走の脚質
					chakuBetsu.setKohan3f(dataSet.getKohan3F());		//後半3F
					chakuBetsu.setWakuban(dataSet.getWakuban());		//枠番
					for(UmagotoDataIndexSet indexSet : indexList){
						if(indexSet.getKettoTorokuBango().equals(kettoTorokuBango)){
							chakuBetsu.setDRun(indexSet.getDrun());		//DRun
						}
					}
					//ツリーセットに格納します
					if(kakuteiChakujun > 0){
						chakuBetsuList.add(chakuBetsu);
					}
				}
				//HomestretchAnalysisを取得します
				List<HomestretchAnalysis> analysisList = new ArrayList<>();
				for(UmagotoDataSet uma : umaNowData){
					HomestretchAnalysis stretch = new HomestretchAnalysis(uma, raceData);
					analysisList.add(stretch);
				}

			%>
		<table>
			<tr>
				<th class="title">項目</th>
			<% for(int i = 1; i <= 18; i++){ %>
				<th class="cell"><% out.print(i + "st"); %></th>
			<% } %>
			</tr>
			<tr>
				<th>馬番</th>
				<%
				for(UmaNowChakujunBetsu data : chakuBetsuList){
				%>
					<td><span class="waku waku<% out.print(data.getWakuban()); %>"><% out.print(data.getUmaban()); %></span></td>
				<%
				}
				%>
			</tr>
			<tr>
				<th>人気</th>
				<%
				for(UmaNowChakujunBetsu data : chakuBetsuList){
					if(data.getNinki() == chakuBetsuList.getSelectRankNinki(1)){
					%>
						<td><span class="ninki backRed bold"><% out.print(data.getNinki()); %></span></td>
					<%
					}else if(data.getNinki() == chakuBetsuList.getSelectRankNinki(2)){
					%>
						<td><span class="ninki backBlue bold"><% out.print(data.getNinki()); %></span></td>
					<%
					}else if(data.getNinki() == chakuBetsuList.getSelectRankNinki(3)){
					%>
						<td><span class="ninki backGreen bold"><% out.print(data.getNinki()); %></span></td>
					<%
					}else{
				%>
					<td><% out.print(data.getNinki()); %></td>
				<%
					}
				}
				%>
			</tr>
			<tr>
				<th>DRun</th>
				<%
				for(UmaNowChakujunBetsu data : chakuBetsuList){
					try{
						if(data.getDRun().equals(chakuBetsuList.getSelectRankDrun(1))){
						%>
							<td><span class="drun backRed bold"><% out.print(data.getDRun()); %></span></td>
						<%
						}else if(data.getDRun().equals(chakuBetsuList.getSelectRankDrun(2))){
						%>
							<td><span class="drun backBlue bold"><% out.print(data.getDRun()); %></span></td>
						<%
						}else if(data.getDRun().equals(chakuBetsuList.getSelectRankDrun(3))){
						%>
							<td><span class="drun backGreen bold"><% out.print(data.getDRun()); %></span></td>
						<%
						}else{
						%>
						<td><% out.print(data.getDRun()); %></td>
						<%
						}
					}catch(NullPointerException e){
					%>
					<td>***</td>
					<%
					}
				}
				%>
			</tr>
			<tr>
				<th>これまでの脚質</th>
				<%
				for(UmaNowChakujunBetsu data : chakuBetsuList){
					switch(data.getKakoKyakushitsu()){
					case "逃げ":
				%>
						<td><span class="underRed"><% out.print(data.getKakoKyakushitsu()); %></span></td>
				<%
					break;
					case "先行":
				%>
						<td><span class="underOrange"><% out.print(data.getKakoKyakushitsu()); %></span></td>
				<%
					break;
					case "差し":
				%>
						<td><span class="underYellow"><% out.print(data.getKakoKyakushitsu()); %></span></td>
				<%
					break;
					case "追込":
				%>
						<td><span class="underBlue"><% out.print(data.getKakoKyakushitsu()); %></span></td>
				<%
					break;
					default:
				%>
						<td><span class="underGray"><% out.print(data.getKakoKyakushitsu()); %></span></td>
				<%
					}
				}
				%>
			</tr>
			<tr>
				<th>実際の脚質</th>
				<%
				for(UmaNowChakujunBetsu data : chakuBetsuList){
					switch(data.getNowKyakushitsu()){
					case "逃げ":
				%>
						<td><span class="underRed"><% out.print(data.getNowKyakushitsu()); %></span></td>
				<%
					break;
					case "先行":
				%>
						<td><span class="underOrange"><% out.print(data.getNowKyakushitsu()); %></span></td>
				<%
					break;
					case "差し":
				%>
						<td><span class="underYellow"><% out.print(data.getNowKyakushitsu()); %></span></td>
				<%
					break;
					case "追込":
				%>
						<td><span class="underBlue"><% out.print(data.getNowKyakushitsu()); %></span></td>
				<%
					break;
					default:
				%>
						<td><span class="underGray"><% out.print(data.getNowKyakushitsu()); %></span></td>
				<%
					}
				}
				%>
			</tr>
			<tr>
				<th>上がり3F</th>
				<%
				for(UmaNowChakujunBetsu data : chakuBetsuList){
					if(data.getKohan3f().equals(chakuBetsuList.getSelectRankKohan3f(1))){
					%>
						<td><span class="kohan3f backRed bold"><% out.print(data.getKohan3f()); %></span></td>
					<%
					}else if(data.getKohan3f().equals(chakuBetsuList.getSelectRankKohan3f(2))){
					%>
						<td><span class="kohan3f backBlue bold"><% out.print(data.getKohan3f()); %></span></td>
					<%
					}else if(data.getKohan3f().equals(chakuBetsuList.getSelectRankKohan3f(3))){
					%>
						<td><span class="kohan3f backGreen bold"><% out.print(data.getKohan3f()); %></span></td>
					<%
					}else{
				%>
					<td><% out.print(data.getKohan3f()); %></td>
				<%
					}
				}
				%>
			</tr>
			<tr>
				<th>ジリ脚</th>
				<%
				for(UmaNowChakujunBetsu data : chakuBetsuList){
					BigDecimal ziriAshi = analysisList.stream()
													  .filter(s -> s.getUmaData().getKettoTorokuBango().equals(data.getKettoTorokuBango()))
													  .map(s -> s.getEscapeCompare())
													  .findFirst()
													  .get();
				%>
				<td><% out.print(ziriAshi); %></td>
				<%
				}
				%>
			</tr>
			<tr>
				<th>詰脚</th>
				<%
				for(UmaNowChakujunBetsu data : chakuBetsuList){
					BigDecimal tsumeAshi = analysisList.stream()
													  .filter(s -> s.getUmaData().getKettoTorokuBango().equals(data.getKettoTorokuBango()))
													  .map(s -> s.getTsumeAshi())
													  .findFirst()
													  .get();
				%>
				<td><% out.print(tsumeAshi); %></td>
				<%
				}
				%>
			</tr>
		</table>
		<h2>ラップから</h2>
		<table>
			<tr>
				<th>距離1</th>
				<%
				for(int i = 200; i <= 2400;){
				%>
					<th><% out.print(i + "m"); %></th>
				<%
				i = i + 200;
				}
				%>
			</tr>
			<tr>
				<th>ラップ1</th>
				<%
				for(int i = 0; i < 12; i++){
					BigDecimal lap = raceData.getLapTime()[i];
					if(raceData.getLapTime()[i].equals(BigDecimal.valueOf(0.0))){
						break;
					}
					//ラップタイムの値によってフォントの色を変更します
					if(lap.compareTo(BigDecimal.valueOf(11.5)) <= 0){
			%>
						<td><span class="underRed"><% out.print(lap); %></span></td>
			<%
					}else if(lap.compareTo(BigDecimal.valueOf(12)) < 0){
			%>
						<td><span class="underOrange"><% out.print(lap); %></span></td>
			<%
					}else if(lap.compareTo(BigDecimal.valueOf(12.5)) > 0){
			%>
						<td><span class="underBlue"><% out.print(lap); %></span></td>
			<%
					}else{
			%>
					<td><span class="underYellow"><% out.print(lap); %></span></td>
			<%
					}
				}
			%>
			</tr>
			<tr>
				<th>距離2</th>
				<%
				for(int i = 2600; i <= 3600;){
				%>
					<th><% out.print(i + "m"); %></th>
				<%
				i = i + 200;
				}
				%>
			</tr>
			<tr>
				<th>ラップ2</th>
				<%
				if(raceData.getLapTime().length > 12){
					for(int i = 12; i < 18; i++){
						BigDecimal lap = raceData.getLapTime()[i];
						if(lap.equals(BigDecimal.valueOf(0.0))){
							break;
						}
						//ラップタイムの値によってフォントの色を変更します
						if(lap.compareTo(BigDecimal.valueOf(11.5)) <= 0){
				%>
							<td><span class="underRed"><% out.print(lap); %></span></td>
				<%
						}else if(lap.compareTo(BigDecimal.valueOf(12)) < 0){
				%>
							<td><span class="underOrange"><% out.print(lap); %></span></td>
				<%
						}else if(lap.compareTo(BigDecimal.valueOf(12.5)) > 0){
				%>
							<td><span class="underBlue"><% out.print(lap); %></span></td>
				<%
						}else{
				%>
							<td><span class="underYellow"><% out.print(lap); %></span></td>
				<%
						}
					}
				}
				%>
			</tr>
		</table>
	</div>
<%
	}
%>

	<!-- *****************************************************************************************
*********************************							**********************************
*********************************	テーブルを作成します(*´ω｀*)	**********************************
*********************************							**********************************************************
********************************************************************************************************************** -->

	<div class="danceIndex">
		<div class="tableTitle">
			<h2>出馬表</h2>

			<div class="hidden_box">
				<input type="radio" id="a" name="btn" checked="checked"><label
					for="a">出馬表</label> <input type="radio" id="b" name="btn"><label
					for="b">過去4走</label> <input type="radio" id="c" name="btn"><label
					for="c">過去結果</label>

				<table class="text kakoResult" id="kakoResult">
					<%
						List<ViewRaceShosai> resultList;
						if (raceData.getKyosomeiHondai().length() > 0) {
							try (RaceShosaiReader reader = new RaceShosaiReader();) {
								//フィールド
								String kyosomei = raceData.getKyosomeiHondai();
								SimpleDateFormat f = new SimpleDateFormat("yyyy年MM月dd日");
								Date kaisai = f.parse(raceData.getKaisaiNenGappi());
								ViewRaceShosaiExample ex = reader.getExample();
								ViewRaceShosaiMapper map = reader.getMapper();
								//Where句
								String tokubetsu = raceData.getTokubetsuTorokuBango();
								if (tokubetsu.equals("0000")) {
									ex.createCriteria().andKyosomeiHondaiEqualTo(kyosomei);
								} else {
									ex.createCriteria().andTokubetsuKyosoBangoEqualTo(tokubetsu);
								}
								ex.setOrderByClause("kaisai_nengappi desc limit 10");
								resultList = map.selectByExample(ex);
								resultList = resultList.stream().filter(s -> s.getKaisaiNengappi().before(kaisai))
										.collect(Collectors.toList());
							}
						} else {
							resultList = new ArrayList<>();
						}
					%>
					<tr>
						<th>開催日</th>
						<th>レース名</th>
						<th>勝ち馬</th>
						<th>Ave3f</th>
						<th>RPCI</th>
						<th>SRun</th>
					</tr>
					<%
						for (ViewRaceShosai result : resultList) {
							String kaisai = new SimpleDateFormat("yyyy年MM月dd日").format(result.getKaisaiNengappi());
					%>
					<tr>

						<td>
							<%
								out.print(kaisai);
							%>
						</td>
						<td><a
							href="/JockeysLink/DanceTableGraph?racecode=<%out.print(result.getRaceCode());%>&mode=dance">
								<%
									out.print(result.getKyosomeiHondai());
								%>
						</a></td>
						<td>
							<%
								out.print(result.getKachiumaBamei());
							%>
						</td>
						<td>
							<%
								out.print(result.getAve3f());
							%>
						</td>
						<td>
							<%
								out.print(result.getRpci());
							%>
						</td>
						<td>
							<%
								out.print(result.getSrunRow());
							%>
						</td>
					</tr>
					<%
						}
					%>
				</table>

				<table class="text kako4sou" id="kako4sou">
					<tr>
						<th>枠番</th>
						<th>馬番</th>
						<%
						if(Integer.valueOf(raceData.getDataKubun()) > 2){
						%>
						<th class="chakujun">着順</th>
						<%
						}
						%>
						<th>印</th>
						<th class="bamei">馬名</th>
						<th>人気</th>
						<th colspan="3">1走前</th>
						<th colspan="3">2走前</th>
						<th colspan="3">3走前</th>
						<th colspan="3">4走前</th>
						<th>Srun<br>Score
						</th>
					</tr>
					<%
					Comparator<UmagotoDataSet> comparator;
					if(dataKubun < 3){
						comparator = new Comparator<UmagotoDataSet>() {
							@Override
							public int compare(UmagotoDataSet o1, UmagotoDataSet o2) {
								return Integer.valueOf(o1.getUmaban()).compareTo(Integer.valueOf(o2.getUmaban()));
							}
						};
					}else{
						comparator = new Comparator<UmagotoDataSet>() {
							@Override
							public int compare(UmagotoDataSet o1, UmagotoDataSet o2) {
								return Integer.valueOf(o1.getKakuteiChakujun()).compareTo(Integer.valueOf(o2.getKakuteiChakujun()));
							}
						};
					}
						Collections.sort(umaNowData, comparator);
						for (int i = 0; i < umaNowData.size(); i++) {
							int umaban = i + 1;
							UmagotoDataSet data = umaNowData.get(i);
							String kettoTorokuBango = data.getKettoTorokuBango();
							//枠番が同じ場合に結合を行います
							int wakuban = data.getWakuban();
							int previousWakuban = 0;
							int nextWakuban = 0;
							int thirdWakuban = 0;
							boolean wakuHantei = true;
							String key;
							if(dataKubun < 3){
								if (i > 0)
									previousWakuban = umaNowData.get(i - 1).getWakuban();
								try {
									nextWakuban = umaNowData.get(i + 1).getWakuban();
									try {
										thirdWakuban = umaNowData.get(i + 2).getWakuban();
									} catch (IndexOutOfBoundsException e2) {
										thirdWakuban = 0;
									}
								} catch (IndexOutOfBoundsException e) {
									nextWakuban = 0;
								}
								key = (wakuban * wakuban) == (nextWakuban * thirdWakuban) ? " rowspan=\"3\""
										: wakuban == nextWakuban ? " rowspan=\"2\"" : "";
								wakuHantei = wakuban == previousWakuban;
							}else{
								key = "";
								wakuHantei = false;
							}
							//着順ごとに色を指定します
							String chakujunColor = "";
							switch (data.getKakuteiChakujun()) {
							case 1:
								chakujunColor = "class=\"chaRed bold\"";
								break;
							case 2:
								chakujunColor = "class=\"chaBlue bold\"";
								break;
							case 3:
								chakujunColor = "class=\"chaGreen bold\"";
								break;
							}
					%>
					<tr>
						<%
							if (wakuHantei == false) {
						%>
						<!-- 枠番 -->
						<td class="waku<%out.print(data.getWakuban());%>"
							<%out.print(key);%>>
							<%
								out.print(data.getWakuban() == 0 ? "仮" : data.getWakuban());
							%>
						</td>
						<%
							} else {
									out.print(data.getWakuban() == 0 ? "仮</td>" : "");
								}
						%>
						<!-- 馬番 -->
						<td class="bottom">
							<%
								out.print(data.getUmaban() == 0 ? umaban : data.getUmaban());
							%>
						</td>
						<!-- 着順 -->
						<td class="bottom" <%out.print(chakujunColor);%>>
							<%
								switch(data.getKakuteiChakujun()){
								case 0:
									out.print("-");
									break;
								default:
									out.print(data.getKakuteiChakujun() + "着");
								}
							%>
						</td>
						<!-- 馬印 -->
						<td class="bottom"><select name="shirushi" class="shirushi">
								<%
									if (srunMapper.get(data.getKettoTorokuBango()) == true) {
								%>
								<option></option>
								<%
									} else {
								%>
								<option selected></option>
								<%
									}
										if (popularUpper.equals(data.getKettoTorokuBango())) {
								%>
								<option value="marumaru" selected>◎</option>
								<%
									} else {
								%>
								<option value="marumaru">◎</option>
								<%
									}
								%>
								<option value="maru">〇</option>
								<option value="kurosankaku">▲</option>
								<option value="sankaku">△</option>
								<%
									if (srunMapper.get(data.getKettoTorokuBango()) == true
												& !popularUpper.equals(data.getKettoTorokuBango())) {
								%>
								<option value="star" selected>★</option>
								<%
									} else {
								%>
								<option value="star">★</option>
								<%
									}
								%>

						</select></td>
						<!-- 馬名 -->
						<td class="bottom" class="left bamei"><a
							href="<%out.print(jrdbUmaData + data.getKettoTorokuBango().subSequence(2, 10));%>"
							target="_blank">
								<%
									out.print(data.getBamei());
								%>
						</a></td>
						<!-- 人気 -->
						<td class="bottom">
							<%
								out.print(data.getTanshoNinkijun());
							%>
						</td>
						<!-- 1走前 -->
						<%
							class SrunList extends ArrayList<BigDecimal> {
									@Override
									public boolean add(BigDecimal deci) {
										if (deci == null) {
											return false;
										} else {
											super.add(deci);
											return true;
										}
									}
								}
								List<BigDecimal> srunList = new SrunList();
								for (int t = 0; t < umaKakoData.size(); t++) {
									//4走目までを取得します
									if (t > 3) {
										break;
									}
									UmagotoDataSet uma = umaKakoData.get(t).get(data.getKettoTorokuBango());
									if (t == 0) {
										try {
											uma.toString(); //nullの場合は"初出走"
										} catch (NullPointerException e) {
											for (int f = 0; f < 12; f++) {
						%>

						<td></td>
						<%
							}
											break;
										}
									}
									//t回前の過去走が存在しないときの例外処理
									try {
										String kakoKyosoTitle = uma.getKyosomeiRyakusho6().length() > 0 ? uma.getKyosomeiRyakusho6()
												: uma.getKyosoShubetsu().substring(uma.getKyosoShubetsu().indexOf("系") + 1,
														uma.getKyosoShubetsu().length()) + uma.getKyosoJoken();

										srunList.add(uma.getSrun());
						%>

						<!-- **** < 競争名 > **** -->
						<%
							String textAlign = "";
										if (uma.getGrade().replace("特別競走", "").length() == 0) {
											textAlign = " center";
						%>
						<td class="center kyosomei">
							<%
								} else {
							%>

						<td class="left kyosomei">
							<%
								}
							%>
							<a href="/JockeysLink/DanceTableGraph?racecode=<% out.print(uma.getRaceCode()); %>&mode=dance">
							<%
											String baba = "";
											String fontColor = "";
											chakujunColor = "";
											switch (uma.getGrade().replace("特別競走", "")) {
											case "ＧⅠ":
												fontColor = " chaRed";
												break;
											case "Ｊ･ＧⅠ":
												fontColor = " chaRed";
												break;
											case "ＧⅡ":
												fontColor = " chaBlue";
												break;
											case "Ｊ･ＧⅡ":
												fontColor = " chaBlue";
												break;
											case "ＧⅢ":
												fontColor = " chaGreen";
												break;
											case "Ｊ･ＧⅢ":
												fontColor = " chaGreen";
												break;
											}

											switch (uma.getKakuteiChakujun()) {
											case 1:
												chakujunColor = " chaRed";
												break;
											case 2:
												chakujunColor = " chaBlue";
												break;
											case 3:
												chakujunColor = " chaGreen";
												break;
											}

											switch (uma.getBaba()) {
											case "芝":
												baba = "turf";
												break;
											case "ダート":
												baba = "dirt";
												break;
											}
											//開催年月日を整形します
											String kaisai = uma.getKaisaiNenGappi();
											DateTimeFormatter dtf = DateTimeFormatter.ofPattern("yyyy年MM月dd日");
											LocalDate ld = LocalDate.parse(kaisai, dtf);
											dtf = DateTimeFormatter.ofPattern("yy MM/dd");
											kaisai = ld.format(dtf);
							%> <%
 	StringBuilder lap = new StringBuilder();
 				for (BigDecimal lapTime : uma.getLap()) {
 					if (lapTime.equals(BigDecimal.valueOf(0.0))) {
 						break;
 					}
 					boolean flag = false;
 					if (lapTime.compareTo(BigDecimal.valueOf(11.5)) < 0) {
 						flag = true;
 						lap.append("<span class=\"chaRed\">");
 					} else if (lapTime.compareTo(BigDecimal.valueOf(12)) < 0) {
 						flag = true;
 						lap.append("<span class=\"chaDarkRed\">");
 					}
 					lap.append(lapTime);
 					if (flag == true) {
 						lap.append("</span>");
 					}
 					lap.append("-");
 				}
 				String lapTime;
 				if (lap.length() == 0) {
 					lapTime = "***";
 				} else {
 					lap.delete(lap.length() - 1, lap.length());
 					lapTime = lap.toString();
 				}
 				StringBuilder cornerJuni = new StringBuilder();
 				if (uma.getCorner1Juni() != 0) {
 					cornerJuni.append(uma.getCorner1Juni());
 				}
 				if (uma.getCorner2Juni() != 0) {
 					if (uma.getCorner1Juni() != 0)
 						cornerJuni.append("-");
 					cornerJuni.append(uma.getCorner2Juni());
 				}
 				if (uma.getCorner3Juni() != 0) {
 					if (uma.getCorner2Juni() != 0)
 						cornerJuni.append("-");
 					cornerJuni.append(uma.getCorner3Juni());
 				}
 				if (uma.getCorner4Juni() != 0) {
 					if (uma.getCorner3Juni() != 0)
 						cornerJuni.append("-");
 					cornerJuni.append(uma.getCorner4Juni());
 				}
 				List<BigDecimal> rk3f = uma.getLap();
 				Collections.reverse(rk3f);
 				BigDecimal raceKohan3f = BigDecimal.valueOf(0.0);
 				for (int x = 0; x < rk3f.size(); x++) {
 					if (rk3f.get(x).equals(BigDecimal.valueOf(0.0))) {
 						rk3f.remove(x--);
 					}
 				}
 				LapList lapList = uma.getLap();
 				//平均ラップを記述します******************************************
 				StringBuilder lapAveTime = new StringBuilder();
 				//前半1000m
 				if(lapList.getZenhan1000mAverageLap().compareTo(BigDecimal.valueOf(12)) < 0){
 					lapAveTime.append("<span class=\"chaRed\">");
 				}else{
 					lapAveTime.append("<span>");
 				}
 				lapAveTime.append(lapList.getZenhan1000mAverageLap().toString());
 				lapAveTime.append("</span>");
 				lapAveTime.append("-");
 				//コーナーラップ
 				if(lapList.getCornerAverageLap().compareTo(BigDecimal.valueOf(12)) < 0){
 					lapAveTime.append("<span class=\"chaRed\">");
 				}else{
 					lapAveTime.append("<span>");
 				}
 				lapAveTime.append(lapList.getCornerAverageLap().toString());
 				lapAveTime.append("</span>");
 				lapAveTime.append("-");
 				//後半3fラップ
 				if(lapList.getKohan3fAverageLap().compareTo(BigDecimal.valueOf(12)) < 0){
 					lapAveTime.append("<span class=\"chaRed\">");
 				}else{
 					lapAveTime.append("<span>");
 				}
 				lapAveTime.append(lapList.getKohan3fAverageLap().toString());
 				lapAveTime.append("</span>");

 				RaceDataSet raceDataKako = new RaceDataLoad(uma.getRaceCode()).getRaceDataSet();
				HomestretchAnalysis stretch = new HomestretchAnalysis(uma, raceDataKako);
				BigDecimal kohan3fTopSa = stretch.getKohan3fDistanceFromTheBeginning().divide(BigDecimal.valueOf(2.4), 1, BigDecimal.ROUND_HALF_UP);

 %>
							<div class="lapTime">
								<p>
									<span>
										<%
											out.print(uma.getKyakushitsu());
										%>
									</span> <span>
										<%
											out.print(cornerJuni.toString());
										%>
									</span> <span>
										<%
											out.print("RPCI：" + uma.getRPCI());
										%>
									</span> <span>
										<%
											out.print("≪" + lapList.getLapType() + "≫");
										%>
									</span>
								</p>
								<p>
									<span>
										<%
											out.print("レース上がり3F：" + lapList.getRaceKohan3f());
										%>
									</span> <span>
										<%
											out.print("上がり3F：" + uma.getKohan3F());
										%>
									</span>
								</p>
								<p>
									<span>
										<%
											out.print("道中：" + stretch.getBeginsForm() + "km/時");
										%>
										<br>
										<%
											out.print("(" + stretch.getBeginsForm_s() + "m/s)");
										%>
									</span>
									<span>
										<%
											out.print("トップフォーム：" + stretch.getTopForm() + "km/時");
										%>
										<br>
										<%
											out.print("(" + stretch.getTopForm_s() + "m/s)");
										%>
									</span>
									<p>
									<span>
										<%
											out.print("勝負位置：" + kohan3fTopSa + "馬身");
										%>
									</span>
									<span>
										<%
											out.print("詰脚：" + stretch.getTsumeAshi() + "m");
										%>
									</span>
									<span>
										<%
											out.print("ジリ脚：" + stretch.getEscapeCompare());
										%>
									</span>
								</p>
								<p>
									<span>
										<%
											out.print("最も速いのは" + lapList.getHiSpeedPoint() * 200 + "m地点");
										%>
									</span> <span>
										<%
											out.print("最も加速したのは" + lapList.getSpeedUpperPoint() * 200 + "m地点");
										%>
									</span>
								</p>
								<p>
									<%
										out.print(lapTime);
									%>
								</p>
								<p>
									<span>
									<%
									out.print(lapList.getRaceType());
									%>
									</span>
									<span>
									<%
									out.print(lapAveTime.toString());
									%>
									</span>
								</p>
							</div>
							<div class="sideBy subTitle">
								<span class="<%out.print(baba);%>"></span>
								<div>
									<%
										out.print("'" + kaisai);
									%>
								</div>
								<div>
									<%
										out.print(uma.getKeibajo());
									%>
								</div>
								<div>
									<%
										out.print(uma.getKyori());
									%>m
								</div>
								<div>
									<%
										out.print(baba == "turf" ? uma.getShibaBabaJotai() : uma.getDirtBabaJotai());
									%>
								</div>
								<p>
							</div>
								<span class="smallFont rpci">
									<%
										out.print("RPCI" + uma.getRPCI());
									%>
								</span>
							<div class="title">
								<div>
									<span class="grade<%out.print(fontColor);%>">
										<%
											out.print(uma.getGrade().replace("特別競走", ""));
										%>
									</span>
									<%
										out.print(kakoKyosoTitle);
										out.print(" " + uma.getKyakushitsu());
									%>
								</div>
							</div>
						</a>
						</td>
						<!-- **** < 着順 > **** -->
						<td class="chakujun<%out.print(chakujunColor);%>">
							<%
								out.print(uma.getIjoKubun().length() > 0 ? uma.getIjoKubun() : uma.getKakuteiChakujun() + "着");
							%>
						</td>
						<!-- **** < SRun > **** -->
						<td class="smallFont srunCell">
							<div>
								<span>
									SRun
								</span>
								<p>
								<span>
								<%
									if (uma.getIjoKubun().length() == 0) {
													try {
														out.print(uma.getSrun().add(BigDecimal.valueOf(12)).multiply(BigDecimal.valueOf(4.5))
																.setScale(2, BigDecimal.ROUND_HALF_UP));
													} catch (NullPointerException e) {
														out.print("****");
													}
												}
								%>
								</span>
							</div>
							<p>
							<div>
								<span>
									ジリ脚
									<p>
									<%
										out.print(stretch.getEscapeCompare());
									%>
								</span>
							</div>
							<p>
							<div>
								<span>
									詰脚
									<p>
									<%
										out.print(stretch.getTsumeAshi());
									%>
								</span>
							</div>
							<p>
							<div>
								<span>
									PCI
									<p>
									<%
										out.print(uma.getPCI());
									%>
								</span>
							</div>
						</td>
						<%
							} catch (NullPointerException e) {
										int z = (4 - t) * 3;
										for (int y = 0; y < z; y++) {
											out.print("<td></td>");
										}
										break;
									}
								}
								BigDecimal bestSrun;
								try {
									bestSrun = srunList.stream().max((a, b) -> a.compareTo(b)).get();
									bestSrun = bestSrun.add(BigDecimal.valueOf(12)).multiply(BigDecimal.valueOf(4.5)).setScale(2,
											BigDecimal.ROUND_HALF_UP);
									BigDecimal srunAve = upperList.stream()
											.filter(s -> s.getKettoTorokuBango().equals(data.getKettoTorokuBango()))
											.map(s -> s.getSrunAve()).findFirst().get();
									srunAve = srunAve.add(BigDecimal.valueOf(12)).multiply(BigDecimal.valueOf(4.5)).setScale(2,
											BigDecimal.ROUND_HALF_UP);
									BigDecimal srunFactor = srunAve.divide(bestSrun, 2, BigDecimal.ROUND_HALF_UP);
									BigDecimal srunScore = srunAve.multiply(srunFactor).setScale(2, BigDecimal.ROUND_HALF_UP);
						%>
						<td>
							<%
								out.print(srunScore);
							%>
						</td>
						<%
							} catch (NoSuchElementException e) {
						%>
						<td>***</td>
						<%
							}
						%>
					</tr>
					<%
						}
					%>
				</table>

				<!-- ******************************************************************************************
************************************************************************************************
********************************		出馬表ここから		****************************************
************************************************************************************************
************************************************************************************************ -->

				<table class="text danceTable">
					<tr>
						<th>枠番</th>
						<th>馬番</th>
						<th>印</th>
						<th>馬名</th>
						<th>性齢</th>
						<th class="desctop">脚質</th>
						<th class="desctop">平均距離</th>
						<th>騎手</th>
						<th class="desctop">斤量</th>
						<th>人気</th>
						<th class="desctop">ｵｯｽﾞ</th>
						<th class="desctop">馬体重</th>
						<th class="desctop">調教師</th>
						<%
						if(dataKubun > 2){
						%>
							<th class="desctop">道中スピード</th>
							<th class="desctop">トップフォーム</th>
							<th class="desctop">後半3F地点位置</th>
							<th class="desctop">着差</th>
							<th class="desctop">詰脚</th>
						<%
						}
						%>
					</tr>
					<%
						for (int i = 0; i < umaNowData.size(); i++) {
							if(umaNowData.get(i).getTanshoNinkijun() <= 0 | !umaNowData.get(i).getIjoKubun().equals("")){
								continue;
							}
							int umaban = i + 1;
							UmagotoDataSet data = umaNowData.get(i);
							String kettoTorokuBango = data.getKettoTorokuBango();
							//枠番が同じ場合に結合を行います
							int wakuban = data.getWakuban();
							int previousWakuban = 0;
							int nextWakuban = 0;
							int thirdWakuban = 0;
							boolean wakuHantei = true;
							String key;
							if(dataKubun < 3){
								if (i > 0)
									previousWakuban = umaNowData.get(i - 1).getWakuban();
								try {
									nextWakuban = umaNowData.get(i + 1).getWakuban();
									try {
										thirdWakuban = umaNowData.get(i + 2).getWakuban();
									} catch (IndexOutOfBoundsException e2) {
										thirdWakuban = 0;
									}
								} catch (IndexOutOfBoundsException e) {
									nextWakuban = 0;
								}
								key = (wakuban * wakuban) == (nextWakuban * thirdWakuban) ? " rowspan=\"3\""
										: wakuban == nextWakuban ? " rowspan=\"2\"" : "";
								wakuHantei = wakuban == previousWakuban;
							}else{
								key = "";
								wakuHantei = false;
							}
					%>
					<tr>
						<%
							if (wakuHantei == false) {
						%>
						<td class="waku<%out.print(data.getWakuban());%>"
							<%out.print(key);%>>
							<%
								out.print(data.getWakuban() == 0 ? "仮" : data.getWakuban());
							%>
						</td>
						<%
							} else {
									out.print(data.getWakuban() == 0 ? "<td>仮</td>" : "");
								}
						%>
						<td>
							<%
								out.print(data.getUmaban() == 0 ? umaban : data.getUmaban());
							%>
						</td>
						<td><select name="shirushi" class="shirushi">
								<option selected></option>
								<option value="marumaru">◎</option>
								<option value="maru">〇</option>
								<option value="kurosankaku">▲</option>
								<option value="sankaku">△</option>
								<option value="star">★</option>
						</select></td>
						<td class="left bamei"><a
							href="<%out.print(jrdbUmaData + data.getKettoTorokuBango().subSequence(2, 10));%>"
							target="_blank">
								<%
									out.print(data.getBamei());
								%>
						</a></td>
						<td>
							<%
								out.print(data.getSeibetsu() + data.getBarei());
							%>

						<td class="desctop">
							<%
								out.print(analysis.getPredictionKyakushitsu(kettoTorokuBango));

							%>

						<td class="desctop">
							<%
								out.print(indexLoad.getAverageKyori(kettoTorokuBango) == 0 ? "-"
											: indexLoad.getAverageKyori(kettoTorokuBango) + "m");
							%>

						<td>
							<%
							try{
								out.print(data.getKishumei().replace("　", ""));
							}catch(NullPointerException e){
								e.getStackTrace();
							}
							%>
						</td>
						<td class="desctop">
							<%
								out.println(data.getFutanJuryo());
							%>
						</td>
						<td>
							<%
								out.println(data.getTanshoNinkijun() == 0 ? "-" : data.getTanshoNinkijun());
							%>
						</td>
						<td class="desctop">
							<%
								out.print(data.getTanshoOdds() == 0 ? "-" : data.getTanshoOdds());
							%>
						</td>
						<td class="desctop">
							<%
								out.print(data.getBataiju() == 0 ? "-" : data.getBataiju() + "kg");
							%>
						</td>
						<td class="left desctop">
							<%
								out.print("（" + data.getTozaiShozoku().substring(0, 1) + "）" + data.getChokyoshi().replace("　", ""));
							%>
						</td>
						<%
						if(dataKubun > 2){
						HomestretchAnalysis stretch = new HomestretchAnalysis(data, raceData);
						BigDecimal kohan3fTopSa = stretch.getKohan3fDistanceFromTheBeginning().divide(BigDecimal.valueOf(2.4), 1, BigDecimal.ROUND_HALF_UP);

						%>
						<td class="desctop">
							<%
								out.print(stretch.getBeginsForm() + "km/時");
							%>
							<br>
							<%
								out.print("(" + stretch.getBeginsForm_s() + "m/s)");
							%>
						</td>
						<td class="desctop">
							<%
								out.print(stretch.getTopForm() + "km/時");
							%>
							<br>
							<%
								out.print("(" + stretch.getTopForm_s() + "m/s)");
							%>
						</td>
						<td class="desctop">
							<%
								out.print(kohan3fTopSa + "馬身");
							%>
							<br>
							<%
								out.print("(" + stretch.getKohan3fDistanceFromTheBeginning() + "m)");
							%>
						</td>
						<td class="desctop">
							<%
								out.print(stretch.getChakusa_m() + "m");
							%>
						</td>
						<td class="desctop">
							<%
								out.print(stretch.getTsumeAshi() + "m");
							%>
						</td>
						<% %>
					</tr>
					<%
						}
						}
					%>
				</table>
				</div>
			</div>
		</div>
</body>
</html>
