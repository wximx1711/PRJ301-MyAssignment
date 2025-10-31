<%@ page import="java.util.*,model.RequestForLeave" %>
<%@ page contentType="text/html; charset=UTF-8" %>
<!DOCTYPE html>
<html><head>
  <meta charset="UTF-8"><title>Danh sách đơn</title>
  <link rel="stylesheet" href="<%=request.getContextPath()%>/css/app.css">
</head>
<body>
  <div class="nav">
    <div class="nav-inner">
      <div class="brand"><div class="logo"></div><span>LM System</span></div>
      <div class="grow"></div>
      <a class="btn" href="<%=request.getContextPath()%>/home">Home</a>
      <a class="btn" href="<%=request.getContextPath()%>/logout">Logout</a>
    </div>
  </div>

  <div class="container">
    <h2 style="margin:10px 0">My Requests</h2>
    <table class="table">
      <tr>
        <th>RID</th><th>From</th><th>To</th><th>Reason</th><th>Status</th><th>Processed By</th>
      </tr>
      <%
        List<RequestForLeave> mine = (List<RequestForLeave>) request.getAttribute("mine");
        if (mine != null) for (RequestForLeave r : mine) {
          String cls = r.getStatus()==1?"bOk":(r.getStatus()==2?"bRej":"bInp");
          String txt = r.getStatus()==1?"Approved":(r.getStatus()==2?"Rejected":"Inprogress");
      %>
      <tr>
        <td><%=r.getRid()%></td>
        <td><%=r.getFromDate()%></td>
        <td><%=r.getToDate()%></td>
        <td><%= (r.getReason()==null||r.getReason().isBlank())?"(no title)":r.getReason() %></td>
        <td><span class="badgeS <%=cls%>"><%=txt%></span></td>
        <td><%= r.getProcessedByName()==null?"-":r.getProcessedByName() %></td>
      </tr>
      <% } %>
    </table>

    <h2 id="review" style="margin:16px 0 10px">Subordinates' Requests</h2>
    <form method="post" action="<%=request.getContextPath()%>/request/review">
      <table class="table">
        <tr>
          <th>RID</th><th>From</th><th>To</th><th>Created By</th><th>Status</th><th>Action</th>
        </tr>
        <%
          List<RequestForLeave> subs = (List<RequestForLeave>) request.getAttribute("subs");
          if (subs != null) for (RequestForLeave r : subs) {
            String txt = r.getStatus()==1?"Approved":(r.getStatus()==2?"Rejected":"Inprogress");
        %>
        <tr>
          <td><%=r.getRid()%></td>
          <td><%=r.getFromDate()%></td>
          <td><%=r.getToDate()%></td>
          <td><%=r.getCreatedByName()%></td>
          <td><%=txt%></td>
          <td class="action">
            <input type="hidden" name="rid" value="<%=r.getRid()%>">
            <button name="status" value="1">Approve</button>
            <button name="status" value="2">Reject</button>
          </td>
        </tr>
        <% } %>
      </table>
    </form>
  </div>
</body></html>
