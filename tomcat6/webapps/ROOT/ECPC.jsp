<%@ page contentType="text/html; charset=Big5" pageEncoding="Big5"%>
<%@ page import="java.io.*"%>
<%@ page import="java.util.*"%>
<%@ page import="com.sonic.*"%>

<HTML>
<HEAD>
<TITLE>Endpoint Check v1.3</TITLE>
</HEAD>
<BODY>

<%
//Announcement
/*
out.print("<font color=\"red\">");
out.print("MAINTAINANCE in progress, please use the link down below: <br>");
out.print("<a href=\"http://10.116.240.153:49161/ECPC.jsp?group=fluentdcluster\">Click me:Endpoint check</a> <br><br><br>");
out.print("</font>");
*/

//==============================================SystemScanner ================================================
		String group = request.getParameter("group");
		
//call linux commands
		//path for docker
		String command = "/var/lib/tomcat6/webapps/ROOT/endpoint_check_V1.9.sh " + group;

		//path for non-docker
		//String command = "/usr/local/tomcat6/webapps/endpointcheck/endpoint_check_V1.8.sh " + group;		

//	out.println(command+"<br>");
		String output = ServerScanner.executeCommand(command);//method executeCommand should put in class ServerScanner or ExecuteShellCommand?
//show bash stdout
     	out.println(output);
		
//Scan the servers
		File source = new File("/tmp/ep-url-"+group+ ".txt");
		//List<String[]> servList = ServerScanner.inputList(group);
		List<String[]> servList = ServerScanner.inputList(source, group);
		
		int servTotal = servList.size();
		
		for(int i = 0; i < servTotal;i++)
			new ServerScanner(servList,i);
		
		int okNum = ServerScanner.countOK(servList);
		int downRate = (int)Math.round((1-((double)okNum/servTotal))*100);

//============================================Show update time=================================================
			Calendar today=Calendar.getInstance();
			int hour=today.get(Calendar.HOUR_OF_DAY);
			int twhour=hour+8;
			int minute=today.get(Calendar.MINUTE);
			int second=today.get(Calendar.SECOND);
			String hh="";
			String mm="";
			String ss="";
  
			if(twhour<10)
                  hh="0"+Integer.toString(twhour);
			else
					hh=Integer.toString(twhour);
  
  
			if(minute<10)
					mm="0"+Integer.toString(minute);
			else
					mm=Integer.toString(minute);
  
  
			if(second<10)
					ss="0"+Integer.toString(second);
			else
					ss=Integer.toString(second);
			
					//out.print("List records: "+records);

//============================================Web page=================================================

 out.print(group);

String url="10.122.97.74";

//workaround
//String urltest="\"http://10.116.240.153:49161/ECPC.jsp?group=";
//timeout method
String urltest="\"http://10.122.97.74:49161/ECPC.jsp?group=";

out.print("<select onchange=\"location.href=this.options[this.selectedIndex].value\"><option value=\"http://10.8.192.200:8081/ECPC.jsp?group=\">choose a service</option> <option value=\"http://"+url+":49161/ECPC.jsp?group=dsife\">dsife</option> <option value=\"http://"+url+":49161/ECPC.jsp?group=imgcrawler\">imgcrawler</option><option value=\"http://"+url+":49161/ECPC.jsp?group=metacrawler\">metacrawler</option><option value=\"http://"+url+":49161/ECPC.jsp?group=docvcs\">docvcs</option><option value=\"http://"+url+":49161/ECPC.jsp?group=dispatcher\">dispatcher</option><option value=\"http://"+url+":49161/ECPC.jsp?group=assocmeta\">assocmeta</option><option value=\"http://"+url+":49161/ECPC.jsp?group=notification\">notification</option><option value=\"http://"+url+":49161/ECPC.jsp?group=sms\">sms</option><option value=\"http://"+url+":49161/ECPC.jsp?group=smscallback\">smscallback</option><option value=\"http://"+url+":49161/ECPC.jsp?group=webhook\">webhook</option><option value=\"http://"+url+":49161/ECPC.jsp?group=jqmonitor\">jqmonitor</option><option value=\"http://"+url+":49161/ECPC.jsp?group=crawlerbackoff\">crawlerbackoff</option><option value=\"http://"+url+":49161/ECPC.jsp?group=ppfe\">ppfe</option><option value="+urltest+"fluentdcluster\""+">fluentdcluster</option> </select>");

		String tobecolored = downRate+"%";			    
			    out.print("<font size=\"7\">");
		   	    out.print("<br>Down rate:");
			    if (downRate>=50){
				out.print("<font color=\"red\">");
				out.print(tobecolored);
				out.print("</font>");
			    }else{
				out.print("<font color=\"green\">");
				out.print(tobecolored);
				out.print("</font>");
			    }
			    out.print("</font>");
			    out.print("<br><br><br>");
	            	    out.println("available: "+(int)okNum+"&nbsp&nbsp&nbsp&nbsp"+"total: "+servTotal+"<br><br><br>");
                 	    out.println("Detail:<br/><table style=\"border: 5px double rgb(109, 2, 107); background-color: rgb(255, 255, 255);\" align=\"left\" cellpadding=\"5\" cellspacing=\"5\" frame=\"border\" rules=\"all\">");
		 out.print("<tr><td>service</td><td>node</td><td>status</td></tr><tr>");
                 for(String[] i:servList){							
                         for(int j = 1; j < i.length; j++)                       
                                 out.print("<td>"+ i[j] +"</td>");
                         out.print("</tr>");
                 }
                 out.print("</table>");

%>

</BODY>
</HTML>
