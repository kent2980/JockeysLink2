<%@ page
	language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"

    import="com.pckeiba.schedule.RaceListLoad"
    import="com.pckeiba.racedata.RaceDataDefault"
    import="com.pckeiba.racedata.RaceDataSetComparetor"
    import="java.util.List"
    import="java.util.Map"
    import="java.util.stream.Collectors"
    import="java.util.Collections"
    import="java.time.LocalDate"
         import="com.util.UtilClass"
%>
<%
	RaceListLoad raceListLoader = UtilClass.AutoCast(request.getAttribute("raceListloader"));
	List<RaceDataDefault> raceList = raceListLoader.getRaceList(raceListLoader.getKeibajoList().get(0));
%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>

<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<link href="../css/newIndex.css" rel="stylesheet">
<link href="/JockeysLink/css/newIndex.css" rel="stylesheet">
<link rel="shortcut icon" href="/JockeysLink/icon/kyosoba_3.ico">
<title>トップページ</title>
</head>
<body>
	<div id="body">
		<div class="heightMenu">
		</div>
		<div class="raceList">
			<table>
				<%
				for(int i = 0; i < raceList.size(); i++){
				%>
				<tr>
				<%
					RaceDataDefault raceData = raceList.get(i);
					String kyosoTitle = raceData.getKyosomeiHondai().length()>0
							?raceData.getKyosomeiRyaku10()
							:raceData.getKyosoShubetsu().substring(raceData.getKyosoShubetsu().indexOf("系")+1, raceData.getKyosoShubetsu().length()) + raceData.getKyosoJoken();
					out.print("<td>" + raceData.getRaceBango() + "R" + "</td>");
					out.print("<td>" + kyosoTitle + "</td>");
				%>
				</tr>
				<%
				}
				%>
			</table>
		</div>
	</div>
	<div id="weightBody">
	</div>
</body>
</html>