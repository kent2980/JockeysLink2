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
   		 import="java.util.Collections"
   		 import="java.time.LocalDate"
   		 import="java.time.LocalDateTime"
   		 import="java.time.format.DateTimeFormatter"
   		 import="java.util.stream.Collectors"
   		 import="java.util.Comparator"
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
<title><%out.print(kyosoTitle); %></title>
</head>
<body id="result">
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
		  		<option<% out.print(raceCodeEquals == true?" selected":""); %> value="/JockeysLink/DanceTableGraph?racecode=<% out.print(race.getRaceCode()); %>&mode=result"><% out.print(selectKyosomei); %></option>
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
        <a href="/JockeysLink/DanceTableGraph?racecode=<% out.print(raceData.getRaceCode()); %>&mode=dance" class ="navi">出馬表</a>
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
<div class="sideBy graph">
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

<!-- ********************** id(myChart)のセッティング **********************-->
		<%
			//リストを確定着順でソートします
			Collections.sort(indexList);
			//失格馬をリストの最後尾に移動します
			List<UmagotoDataIndexSet> errorList = new ArrayList<>();
			for(UmagotoDataIndexSet set: indexList){
				if(set.getKauteiChakujun() == 0){
					errorList.add(set);
				}
			}
			indexList = indexList.stream()
								 .filter(s -> s.getKauteiChakujun() > 0)
								 .collect(Collectors.toList());
			try{
				for(UmagotoDataIndexSet set: errorList){
					indexList.add(set);
				}
			}catch(IndexOutOfBoundsException e){
				errorList = null;
			}
		%>

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
                			//ラベル内のデータを準備します
                			String bamei = uma1.getBamei();
                			int ninkijun = uma1.getTanshoNinkijun();
                			String ninki = ninkijun>0?String.valueOf(ninkijun):"-";
                			//ラベルを出力します
							out.print("\"" + umaban + ". " + uma1.getBamei() + " / " + ninki + "人気\"");
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
                                min: 20,
                                max: 70,
                                fontSize: 13.5
                            },
                        }],
                    }
            };
        </script>


<!-- ****************** グラフ切り替えボタン ******************-->


<!-- ***************************************************************************************
     **********************				youtube埋め込み動画			************************
     *************************************************************************************** -->
<%
	String dateKey = raceData.getKaisaiNenGappi();
	DateTimeFormatter dtf1 = DateTimeFormatter.ofPattern("yyyy年MM月dd日");
	DateTimeFormatter dtf2 = DateTimeFormatter.ofPattern("y／M／d");
	LocalDate ld = LocalDate.parse(dateKey, dtf1);
	dateKey = ld.toString();
	String kaisaiKey = raceData.getKeibajo() + raceData.getRaceBango() + "R";
	String bameiKey = raceData.getWinningHorse();
	String searchKey = dateKey + " " + kaisaiKey + " " + bameiKey;
%>
<div id="youtube">
	<iframe width="480" height="270" src="https://www.youtube.com/embed?listType=search&list=<% out.print(searchKey); %>" frameborder="0" allow="accelerometer; autoplay; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>
	<!-- <img src="https://img.youtube.com/vi/動画ID/mqdefault.jpg" alt="" width="320" height="180" /> -->
</div>
<script src="https://ajax.aspnetcdn.com/ajax/jQuery/jquery-1.12.3.min.js"></script>
<script>// <![CDATA[
$('.youtube').click(function(){
video = '<iframe src="'+ $(this).attr('data-video') +'" frameborder="0" width="480" height="270"></iframe>';
$(this).replaceWith(video);
});
// ]]>
</script>
</div>
<!-- ***************************************************************************************
     **********************					着順掲示板				************************
     *************************************************************************************** -->
     <%
     //umaNowDataを着順でソートします
     Collections.sort(umaNowData, new Comparator<UmagotoDataSet>(){
    	@Override
    	 public int compare(UmagotoDataSet o1, UmagotoDataSet o2){
    		 int chakujun1 = o1.getKakuteiChakujun();
    		 int chakujun2 = o2.getKakuteiChakujun();
    		 if(chakujun1 > chakujun2){
    			 return 1;
    		 }else if(chakujun1 == chakujun2){
    			 return 0;
    		 }else{
    			 return -1;
    		 }
    	}
     });
		//失格馬をリストの最後尾に移動します
		List<UmagotoDataSet> errorList2 = new ArrayList<>();
		for(UmagotoDataSet set: umaNowData){
			if(set.getKakuteiChakujun() == 0){
				errorList2.add(set);
			}
		}
		umaNowData = umaNowData.stream()
							 .filter(s -> s.getKakuteiChakujun() > 0)
							 .collect(Collectors.toList());
		try{
			for(UmagotoDataSet set: errorList2){
				umaNowData.add(set);
			}
		}catch(IndexOutOfBoundsException e){
			errorList2 = null;
		}
     %>
<div id="resultTable">
<div class="tableTitle">
<table>
	<tr>
		<th>着順</th>
		<th>枠番</th>
		<th>馬番</th>
		<th>馬名</th>
		<th>性齢</th>
		<th>斤量</th>
		<th>騎手</th>
		<th>人気</th>
		<th>オッズ</th>
		<th>後半3F</th>
		<th>タイム</th>
		<th>スピード指数</th>
		<th>通過順位</th>
		<th>調教師</th>
	</tr>
	<% for(int i = 0; i < indexList.size(); i++) {
			UmagotoDataSet dataSet = umaNowData.get(i);
			StringBuilder tsukaJuni = new StringBuilder();
			//角通過順位を纏めます
			if(dataSet.getCorner1Juni() > 0){
				tsukaJuni.append(dataSet.getCorner1Juni());
			}if(dataSet.getCorner2Juni() > 0){
				if(dataSet.getCorner1Juni() > 0)
				tsukaJuni.append("-");
				tsukaJuni.append(dataSet.getCorner2Juni());
			}if(dataSet.getCorner3Juni() > 0){
				if(dataSet.getCorner2Juni() > 0)
				tsukaJuni.append("-");
				tsukaJuni.append(dataSet.getCorner3Juni());
			}if(dataSet.getCorner4Juni() > 0){
				if(dataSet.getCorner3Juni() > 0)
				tsukaJuni.append("-");
				tsukaJuni.append(dataSet.getCorner4Juni());
			}
			//異常区分のフラグを作成します
			boolean ijoFlag = dataSet.getKakuteiChakujun() == 0 ? true : false;
	%>
	<tr>
		<td><% out.print(ijoFlag==false?dataSet.getKakuteiChakujun():"-"); %></td>
		<td class="waku<% out.print(dataSet.getWakuban()); %>"><% out.print(dataSet.getWakuban()); %></td>
		<td><% out.print(dataSet.getUmaban()); %></td>
		<td><a href="<% out.print(netkeibaHorse + dataSet.getKettoTorokuBango()); %>" target="_blank"><% out.print(dataSet.getBamei()); %></a></td>
		<td><% out.print(dataSet.getSeibetsu() + dataSet.getBarei()); %></td>
		<td><% out.print(dataSet.getFutanJuryo()); %></td>
		<td><% out.print(dataSet.getKishumei().replace("　", "")); %></td>
		<td><% out.print(ijoFlag==false?dataSet.getTanshoNinkijun():""); %></td>
		<td><% out.print(ijoFlag==false?dataSet.getTanshoOdds():""); %></td>
		<td><% out.print(ijoFlag==false?dataSet.getKohan3F():""); %></td>
		<td><% out.print(ijoFlag==false?dataSet.getSohaTimeValue():dataSet.getIjoKubun()); %></td>
		<td><% out.print(ijoFlag==false?dataSet.getSrun():""); %></td>
		<td><% out.print(ijoFlag==false?tsukaJuni.toString():""); %></td>
		<td><% out.print("（" + dataSet.getTozaiShozoku().substring(0, 1) + "）" + dataSet.getChokyoshi().replace("　", "")); %></td>
	</tr>
	<% } %>
</table>
</div>
</div>
</body>
</html>