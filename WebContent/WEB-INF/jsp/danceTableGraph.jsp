<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page import="com.pckeiba.racedata.RaceDataSet"
         import="com.pckeiba.umagoto.UmagotoDataSet"
         import="com.pckeiba.umagoto.UmagotoDrunSet"
         import="com.pckeiba.umagoto.UmagotoDataIndexLoad"
         import="com.pckeiba.umagoto.UmagotoDataIndexSet"
         import="com.pckeiba.analysis.UmagotoAnalysis"
         import="com.pckeiba.schedule.RaceListLoad"
         import="com.pckeiba.racedata.RaceDataDefault"
         import="java.util.List"
         import="java.util.Map"
         import="java.io.PrintWriter"
         import="com.util.UtilClass"
         import="java.math.BigDecimal"
         import="java.lang.IndexOutOfBoundsException"
   		 import="java.time.LocalDate"
   		 import="java.util.HashMap"
   		 import="java.util.ArrayList"
   		 import="java.time.LocalDate"
   		 import="java.time.format.DateTimeFormatter"
%>
<%
RaceDataSet raceData = (RaceDataSet) request.getAttribute("raceData");
List<UmagotoDataSet> umaNowData = UtilClass.AutoCast(request.getAttribute("umaList"));
List<Map<String,UmagotoDataSet>> umaKakoData = UtilClass.AutoCast(request.getAttribute("umaMap"));
List<UmagotoDrunSet> drunList = UtilClass.AutoCast(request.getAttribute("drunList"));
UmagotoDataIndexLoad indexLoad = UtilClass.AutoCast(request.getAttribute("index"));
List<UmagotoDataIndexSet> indexList = indexLoad.getIndexList();
UmagotoAnalysis analysis = (UmagotoAnalysis) request.getAttribute("analysis");
RaceListLoad raceList = UtilClass.AutoCast(request.getAttribute("raceList"));
PrintWriter pw = response.getWriter();
String kyosoTitle = raceData.getKyosomeiHondai().length()>0
				?raceData.getKyosomeiRyaku10()
				:raceData.getKyosoShubetsu().substring(raceData.getKyosoShubetsu().indexOf("系")+1, raceData.getKyosoShubetsu().length()) + raceData.getKyosoJoken();

/************************<変数の説明>****************************
* raceData = 指定したレースコードのレースデータを取得します
* umaNowData = 指定したレースコードの馬毎データを取得します
* umaKakoData = 過去走の馬毎データを取得します
* drunList = 馬毎のDRunを取得します
***************************************************************/
	String netkeibaRaceCode = raceData.getRaceCode().substring(0, 4) + raceData.getRaceCode().substring(8, 16);
	String netkeiba = "http://race.netkeiba.com/?pid=race&id=c" + netkeibaRaceCode + "&mode=result";
	String netkeibaOdds = "https://ipat.netkeiba.com/?pid=ipat_input&rid=" + netkeibaRaceCode;
	String netkeibaHorse = "https://db.netkeiba.com/horse/";//-> 血統登録番号で指定する

%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<link href="https://fonts.googleapis.com/earlyaccess/roundedmplus1c.css" rel="stylesheet" />
<link href="../css/danceTableGraph.css" rel="stylesheet">
<link href="/JockeysLink/css/danceTableGraph.css" rel="stylesheet">
<link rel="shortcut icon" href="/JockeysLink/icon/kyosoba_3.ico">
<script type="text/javascript" src="https://ajax.googleapis.com/ajax/libs/jquery/1.9.1/jquery.min.js"></script>
<script type="text/javascript" src="../js/pop.js"></script>
<script type="text/javascript" src="/JockeysLink/js/pop.js"></script>
<title><%out.print(kyosoTitle); %></title>
</head>
<body id="dance">

<!-- *****************************************************************************************
     *****************************************************************************************
     							レースデータを記述します
     *****************************************************************************************
     ***************************************************************************************** -->
<div id="title">
  <% int year = LocalDate.now().getYear(); %>
  <a href="/JockeysLink/kaisaichedule?year=<% out.print(year); %>">
  <div id="logo">
    <!-- <img src="../picture/logo.jpg" alt="トップページへのリンク" class="logo"> -->
    <img src="/JockeysLink/picture/logo.jpg" alt="トップページへのリンク" class="logo">
    <span class="title">Jockeys->Link</span>
  </div>
  </a>
  <div id="roundData">
  	  <span class="kaisai"><% out.print(raceData.getKaisaiNenGappi() + "（" + raceData.getYobi() + "）"); %></span>
	  <span class="keibajo"><% out.print(raceData.getKeibajo()); %></span>
	  <span class="round"><% out.print(raceData.getRaceBango() + "R"); %></span>
  </div>
  <div id="kyosomei">
  	<% String jushoKaiji = raceData.getJushoKaijiCode()==0?"":"第" + raceData.getJushoKaiji() + "回"; %>
    <span class="kaiji"><% out.print(jushoKaiji); %></span>
  	<span class="kyosomei"><% out.print(kyosoTitle); %></span>
  </div>
  <div id="raceData">
	  <div class="raceSelect">
	  	<form name="fm">
		  	<select name="s" class="raceSelect" onchange="urlJump()">
		  		<option value="" hidden disabled selected></option>
		  		<%
	  			List<RaceDataDefault> raceDataList = raceList.getRaceList();
		  		for(int i = 0; i < raceDataList.size(); i++){
		  			RaceDataDefault race = raceDataList.get(i);
		  			boolean raceCodeEquals = raceData.getRaceCode().equals(race.getRaceCode());
		  			String kyosomei = race.getKyosomeiHondai().length()>0
		  									?race.getKyosomeiRyaku10()
		  									:race.getKyosoShubetsu().substring(race.getKyosoShubetsu().indexOf("系")+1, race.getKyosoShubetsu().length()) + race.getKyosoJoken();
		  			String selectKyosomei = race.getKeibajo() + " - " + String.format("%02d", race.getRaceBango()) + "R　" + kyosomei;
		  		%>
		  		<option<% out.print(raceCodeEquals == true?" selected":""); %> value="/JockeysLink/DanceTableGraph?racecode=<% out.print(race.getRaceCode()); %>&mode=dance"><% out.print(selectKyosomei); %></option>
		  		<%
		  		}
		  		%>
		  	</select>
	  	</form>
	  </div>
	  <div id="data">
		  <div class="courseData desctop">
		    <span><% out.print(raceData.getKyori() + "m"); %></span>
		    <span><% out.print(raceData.getTrackCode()); %></span>
		    <span><% out.print(raceData.getHassoJikoku()); %></span>
		  </div>
		  <div class="raceData desctop">
		  	<span><% out.println(raceData.getKyosoJoken()); %></span>
		  	<span><% out.println(raceData.getKyosoShubetsu()); %></span>
		  	<span><% out.println(raceData.getKyosoKigo()); %></span>
		  	<span><% out.print(raceData.getJuryoShubetsu()); %></span>
		  	<span><% out.print(raceData.getTorokuTosu() + "頭"); %></span>
		  	<!--  <span>＜<% //out.print(indexLoad.getDrunMargin(1) + "pt"); %>＞</span> -->
		  </div>
	  </div>
  </div>
    <div id="menu">
      <div>
        <span class ="navi">分析</span>
      </div>
          <div>
            <a href="<% out.print(netkeibaOdds); %>" target="_blank" class ="navi">IPAT</a>
          </div>
          <div>
            <a href="/JockeysLink/DanceTableGraph?racecode=<% out.print(raceData.getRaceCode()); %>&mode=result" class ="navi">結果</a>
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
        <div id="timeChart" class="Chart" width:"100%">
        	<h2 class=title>タイムランク</h2>
        	<canvas id="myChart" width="100" height="<% out.print(height); %>"></canvas>
		</div>

        <!-- ②Chart.jsの読み込み -->
        <script src="https://cdnjs.cloudflare.com/ajax/libs/Chart.js/2.7.2/Chart.bundle.min.js"></script>

		<!-- ③チャート描画情報の作成 -->
		<script>
			window.onload = function() {
			    ctx = document.getElementById("myChart").getContext("2d");
			    window.myBar = new Chart(ctx, {
			        type: 'bar',
			        data: barChartData,
			        options: complexChartOption
			    });
			};
		</script>

        <!-- ④チャートデータの作成 -->
        <script>
            var barChartData = {
                	labels: [<%
                		for(int i = 0; i < indexList.size(); i++){
                			UmagotoDataIndexSet uma1 = indexList.get(i);
                    		int umaban = uma1.getUmaban()==0 ? i + 1 : uma1.getUmaban();
                    		String kettoBango = indexList.get(i).getKettoTorokuBango();
                			UmagotoDataSet zenso = umaKakoData.get(0).get(kettoBango);
                			//開催年月日をフォーマットする
                			String kaisaiNenGappi = zenso.getKaisaiNenGappi();
                			DateTimeFormatter dtf1 = DateTimeFormatter.ofPattern("yyyy年MM月dd日");
                			DateTimeFormatter dtf2 = DateTimeFormatter.ofPattern("y／M／d");
                			LocalDate ld = LocalDate.parse(kaisaiNenGappi, dtf1);
                			kaisaiNenGappi = dtf2.format(ld);
                			//ラベルを出力します
							out.print("[\"" + umaban + ". " + uma1.getBamei() + " / " + uma1.getTanshoNinkijun() + "人気\", \"（前走：" + kaisaiNenGappi + "）\"]");
							if(i + 1 < indexList.size()){
								out.print(",");
							}
                		}
                	%>],
                    datasets: [
                    {
                    	type: 'bar',
                        label: 'タイムランク',
                    	data: [<%
                    		for(int i = 0; i < indexList.size(); i++){
                    			UmagotoDataIndexSet uma1 = indexList.get(i);
								out.print(uma1.getDrun());
								if(i + 1 < indexList.size()){
									out.print(",");
								}
                    		}
                    	%>],
                    	backgroundColor : [<%
                            String escape = "'rgba(255, 57, 59, 0.8)'";
                        	String preceding = "'rgba(255, 140, 60, 0.8)'";
                        	String insert = "'rgba(246, 255, 69, 0.8)'";
                        	String last = "'rgba(57, 157, 255, 0.8)'";
                        	String defaultColor = "'rgba(184, 184, 184, 0.8)'";
                        	for(int i = 0; i < indexList.size(); i++){
								String kettoTorokuBango = indexList.get(i).getKettoTorokuBango();
								int kyakushitsu = analysis.getPredictionKyakushitsuHantei(kettoTorokuBango);
								switch(kyakushitsu){
								case 1:
									out.print(escape);
									break;
								case 2:
									out.print(preceding);
									break;
								case 3:
									out.print(insert);
									break;
								case 4:
									out.print(last);
									break;
								default:
									out.print(defaultColor);
								}
								if(i + 1 < indexList.size()){
									out.print(",");
								}
                        	}
                        %>],
                        borderWidth: 1
                    },
                    {
                    	type: 'line',
                    	label: 'トップスピード',
                    	data: [<%
                    		for(int i = 0; i < indexList.size(); i++){
                    			UmagotoDataIndexSet uma1 = indexList.get(i);
								out.print(uma1.getSpeedRate());
								if(i + 1 < indexList.size()){
									out.print(",");
								}
                    		}
                    	%>],
                    	borderColor : 'rgba(54,164,235)',
                        backgroundColor : 'rgba(54,164,235,0.5)'
                    },
                    {
                    	type: 'line',
                    	label: '1走前タイムランク',
                    	data: [<%
                    		for(int i = 0; i < indexList.size(); i++){
                    			String kettoBango = indexList.get(i).getKettoTorokuBango();
                    			UmagotoDataSet uma1 = umaKakoData.get(0).get(kettoBango);
                    			try{
                    				BigDecimal srun = (uma1.getSrun().add(BigDecimal.valueOf(12))).multiply(BigDecimal.valueOf(4.5)).setScale(2, BigDecimal.ROUND_HALF_UP);
    								out.print(srun);
                    			}catch(NullPointerException e){
                    				out.print("0");
                    			}
								if(i + 1 < indexList.size()){
									out.print(",");
								}
                    		}
                    	%>],
                    	borderColor : 'rgba(254,164,65)',
                        backgroundColor : 'rgba(254,164,65,0.1)'
                    },
                    {
                    	type: 'line',
                    	label: '1走前RPCI',
                    	data: [<%
                    		for(int i = 0; i < indexList.size(); i++){
                    			String kettoBango = indexList.get(i).getKettoTorokuBango();
                    			UmagotoDataSet uma1 = umaKakoData.get(0).get(kettoBango);
                    			try{
                    				BigDecimal rpci = uma1.getRPCI();
    								out.print(rpci);
                    			}catch(NullPointerException e){
                    				out.print("0");
                    			}
								if(i + 1 < indexList.size()){
									out.print(",");
								}
                    		}
                    	%>],
                    	borderColor : 'rgb(221, 226, 15)',
                        backgroundColor : 'rgba(241, 252, 27,0.1)'
                    }
                    ],
            };
		</script>

		<!-- ⑤オプションの作成 -->
		<%
	    int minDrun = indexList.stream()
	    					   .filter(s -> s.getDrun() != null)
		   					   .mapToInt(s -> s.getDrun().setScale(-1, BigDecimal.ROUND_DOWN).intValue())
		   					   .min().getAsInt();
	    int minSpeedRate = indexList.stream()
	    							.filter(s -> s.getSpeedRate() != null)
					 				.mapToInt(s -> s.getSpeedRate().setScale(-1, BigDecimal.ROUND_DOWN).intValue())
								    .min().getAsInt();
	    int minYscale = minDrun < minSpeedRate ? minDrun : minSpeedRate;
		%>
		<script>
		var complexChartOption = {
				  tooltips: {
				  },
	              responsive: true,
                    scales: {
                    	xAxes: [{
                    		ticks: {
                    			autoSkip: false,
                    			fontSize: 12,
                    			minRotation: 20
                    		},
                    	}],
                        yAxes: [{
                            ticks: {
                                beginAtZero:true,
                                min: <% out.print(minYscale); %>,
                                max: 70,
                                fontSize: 13.5
                            },
                        }],
                    }
            };
        </script>

<!-- *****************************************************************************************
     **********************************グラフ記述ここまで*******************************************
     ***************************************************************************************** -->

<!-- *****************************************************************************************
*********************************							**********************************
*********************************	テーブルを作成します(*´ω｀*)	**********************************
*********************************							**********************************************************
********************************************************************************************************************** -->

	<div class="danceIndex">
		<div class="tableTitle">
		<h2>出馬表</h2>
		
<div class="hidden_box">
  <input type="radio" id="a" name="btn" checked="checked"><label for="a">出馬表</label>
  <input type="radio" id="b" name="btn"><label for="b">過去4走</label>
  
  <table class="text kako4sou">
      <tr>
        <th>枠番</th>
        <th>馬番</th>
        <th>印</th>
        <th>馬名</th>
      </tr>
      			<% for(int i = 0; i < umaNowData.size(); i++){
					int umaban = i + 1;
					UmagotoDataSet data = umaNowData.get(i);
					String kettoTorokuBango = data.getKettoTorokuBango();
					//枠番が同じ場合に結合を行います
					int wakuban = data.getWakuban();
					int previousWakuban = 0;
					int nextWakuban = 0;
					int thirdWakuban = 0;
					if(i > 0)
						previousWakuban = umaNowData.get(i - 1).getWakuban();
					try{
						nextWakuban = umaNowData.get(i + 1).getWakuban();
						try{
							thirdWakuban = umaNowData.get(i + 2).getWakuban();
						}catch(IndexOutOfBoundsException e2){
							thirdWakuban = 0;
						}
					}catch(IndexOutOfBoundsException e){
						nextWakuban = 0;
					}
					String key = (wakuban * wakuban) == (nextWakuban * thirdWakuban) ? " rowspan=\"3\"" : wakuban == nextWakuban ? " rowspan=\"2\"" : "";
					boolean wakuHantei = wakuban == previousWakuban;
			%>
			<tr>
				<%
					if(wakuHantei == false){
				%>
				<td class="waku<% out.print(data.getWakuban()); %>"<% out.print(key); %>><% out.print(data.getWakuban()==0?"仮":data.getWakuban()); %></td>
				<%
					}else{
						out.print(data.getWakuban()==0?"<td>仮</td>":"");
					}
				%>
				<td><% out.print(data.getUmaban()==0 ? umaban : data.getUmaban()); %></td>
				<td>
					<select name="shirushi" class="shirushi">
						<option selected></option>
						<option value="marumaru">◎</option>
						<option value="maru">〇</option>
						<option value="kurosankaku">▲</option>
						<option value="sankaku">△</option>
						<option value="star">★</option>
					</select>
				</td>
				<td class="left"><a href="<% out.print(netkeibaHorse + data.getKettoTorokuBango()); %>" target="_blank"><% out.print(data.getBamei()); %></a></td>
				</tr>
				<%} %>
    </table>
		
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
				<th class="desctop">毛色</th>
			</tr>
			<% for(int i = 0; i < umaNowData.size(); i++){
					int umaban = i + 1;
					UmagotoDataSet data = umaNowData.get(i);
					String kettoTorokuBango = data.getKettoTorokuBango();
					//枠番が同じ場合に結合を行います
					int wakuban = data.getWakuban();
					int previousWakuban = 0;
					int nextWakuban = 0;
					int thirdWakuban = 0;
					if(i > 0)
						previousWakuban = umaNowData.get(i - 1).getWakuban();
					try{
						nextWakuban = umaNowData.get(i + 1).getWakuban();
						try{
							thirdWakuban = umaNowData.get(i + 2).getWakuban();
						}catch(IndexOutOfBoundsException e2){
							thirdWakuban = 0;
						}
					}catch(IndexOutOfBoundsException e){
						nextWakuban = 0;
					}
					String key = (wakuban * wakuban) == (nextWakuban * thirdWakuban) ? " rowspan=\"3\"" : wakuban == nextWakuban ? " rowspan=\"2\"" : "";
					boolean wakuHantei = wakuban == previousWakuban;
			%>
			<tr>
				<%
					if(wakuHantei == false){
				%>
				<td class="waku<% out.print(data.getWakuban()); %>"<% out.print(key); %>><% out.print(data.getWakuban()==0?"仮":data.getWakuban()); %></td>
				<%
					}else{
						out.print(data.getWakuban()==0?"<td>仮</td>":"");
					}
				%>
				<td><% out.print(data.getUmaban()==0 ? umaban : data.getUmaban()); %></td>
				<td>
					<select name="shirushi" class="shirushi">
						<option selected></option>
						<option value="marumaru">◎</option>
						<option value="maru">〇</option>
						<option value="kurosankaku">▲</option>
						<option value="sankaku">△</option>
						<option value="star">★</option>
					</select>
				</td>
				<td class="left"><a href="<% out.print(netkeibaHorse + data.getKettoTorokuBango()); %>" target="_blank"><% out.print(data.getBamei()); %></a></td>
				<td><% out.print(data.getSeibetsu() + data.getBarei()); %>
				<td class="desctop"><% out.print(analysis.getPredictionKyakushitsu(kettoTorokuBango)); %>
				<td class="desctop"><% out.print(indexLoad.getAverageKyori(kettoTorokuBango)==0?"-":indexLoad.getAverageKyori(kettoTorokuBango) + "m"); %>
				<td><% out.print(data.getKishumei().replace("　", "")); %></td>
				<td class="desctop"><% out.println(data.getFutanJuryo()); %></td>
				<td><% out.println(data.getTanshoNinkijun()==0?"-":data.getTanshoNinkijun()); %></td>
				<td class="desctop"><% out.print(data.getTanshoOdds()==0?"-":data.getTanshoOdds()); %></td>
				<td class="desctop"><% out.print(data.getBataiju()==0?"-":data.getBataiju() + "kg"); %></td>
				<td class="left desctop"><% out.print("（" + data.getTozaiShozoku().substring(0, 1) + "）" + data.getChokyoshi().replace("　", "")); %></td>
				<td class="desctop"><% out.print(data.getMoshoku()); %></td>
			</tr>
			<% } %>
		</table>
		</div>

</div>
</body>
</html>