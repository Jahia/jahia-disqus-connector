<%@ page import="org.apache.commons.lang.StringUtils" %>
<%@ page import="org.jahia.services.content.JCRNodeWrapper" %>
<%@ page import="javax.jcr.RepositoryException" %>
<%@ page import="javax.jcr.Value" %>
<%@ page import="java.util.HashSet" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ taglib prefix="form" uri="http://www.springframework.org/tags/form" %>
<%@ taglib prefix="functions" uri="http://www.jahia.org/tags/functions" %>
<%@ taglib prefix="jcr" uri="http://www.jahia.org/tags/jcr" %>
<%@ taglib prefix="template" uri="http://www.jahia.org/tags/templateLib" %>
<%@ taglib prefix="uiComponents" uri="http://www.jahia.org/tags/uiComponentsLib" %>
<%@ taglib prefix="utility" uri="http://www.jahia.org/tags/utilityLib" %>
<%@ taglib prefix="user" uri="http://www.jahia.org/tags/user" %>
<%@ taglib prefix="facet" uri="http://www.jahia.org/tags/facetLib" %>
<%--@elvariable id="currentNode" type="org.jahia.services.content.JCRNodeWrapper"--%>
<%--@elvariable id="currentResource" type="org.jahia.services.render.Resource"--%>
<%--@elvariable id="flowRequestContext" type="org.springframework.webflow.execution.RequestContext"--%>
<%--@elvariable id="out" type="java.io.PrintWriter"--%>
<%--@elvariable id="renderContext" type="org.jahia.services.render.RenderContext"--%>
<%--@elvariable id="script" type="org.jahia.services.render.scripting.Script"--%>
<%--@elvariable id="scriptInfo" type="java.lang.String"--%>
<%--@elvariable id="url" type="org.jahia.services.render.URLGenerator"--%>
<%--@elvariable id="workspace" type="java.lang.String"--%>
<c:set var="boundComponent"
       value="${uiComponents:getBindedComponent(currentNode, renderContext, 'j:bindedComponent')}"/>
<template:addResources type="javascript" resources="disqusUtils.js"/>
<template:addResources type="css" resources="disqus.css"/>
<jcr:node var="disqusNode" path="${renderContext.site.path}/disqusSettings"/>
<jcr:nodeProperty var="shortname" node="${disqusNode}" name="shortname"/>
<jcr:nodeProperty var="publicKey" node="${disqusNode}" name="publicKey"/>
<c:set var="shortnameValue" value="${shortname.string}"/>
<c:if test="${!empty currentNode.properties['shortname'].string}">
    <c:set var="shortnameValue" value="${currentNode.properties['shortname'].string}"/>
</c:if>
<c:url var="disqusSettingsURL" value="${url.baseEdit}${renderContext.site.path}.disqus.html"/>
<template:addResources>
    <script type="text/javascript">
        var context = "${url.context}";
        var API_URL_START = "modules/api/jcr/v1";
        var locale = "${renderContext.UILocale}";
        var readUrl = context+"/"+API_URL_START+"/live/"+locale+"/paths${renderContext.site.path}/disqusSettings";
        var public_key;
        var shortname;
        var show=true;

        /**
         * THis function call the Disqus API to get the thread posts count
         * @param shortname : The Disqus account shortname
         * @param publicKey : The Disqus account public Key
         * @param url : The page URL
         */
        function getPostsCount(shortname,publicKey, url)
        {
            var getUrl = "https://disqus.com/api/3.0/threads/details.json?api_key="+publicKey+"&forum="+shortname+"&thread=link:"+url;
            $.get(getUrl,function(data) {
                //Generating datatable innerHTML from API response JSON
                var count = data.response.posts;
                $("#showThreads").html("<fmt:message key="jnt_disqusThread.showComments"/> ("+count+")");
            });
        }

        //Getting Disqus parameter from JCR Live Disqus Settings
        $(document).ready(function(){
            $.get(readUrl,function(data) {
                shortname = data.properties.shortname.value;
            });
            getPostsCount("${shortname.string}","${publicKey.string}",window.location.href);
        });

    </script>
</template:addResources>
<jcr:node var="disqusNode" path="${renderContext.site.path}/disqusSettings"/>
<jcr:nodeProperty var="shortname" node="${disqusNode}" name="shortname"/>
<c:choose>
    <c:when test="${empty shortname.string}">
        <c:if test="${renderContext.editMode}">
            <div class="disqusCommentsBlock" id="${boundComponent.identifier}" style="margin-bottom:15px;">
                Please set your Disqus Parameters <a href="${disqusSettingsURL}"> <span class="btn btn-primary">here</span></a> to display a Disqus Thread
            </div>
        </c:if>
    </c:when>
    <c:otherwise>
        <c:if test="${not empty boundComponent}">
            <c:choose>
                <c:when test="${renderContext.editMode}">
                    <fmt:message key="jnt_disqusThread.threadWillBeDisplayed"/>
                    <%@include file="../../jnt_disqusConnector/html/disqus.loader.jspf" %>
                </c:when>
                <c:otherwise>
                    <div class="disqusCommentsBlock" id="${boundComponent.identifier}" style="margin-bottom:15px;">
                        <template:addResources>
                            <noscript>Please enable JavaScript to view the <a href="http://disqus.com/?ref_noscript">comments powered by Disqus.</a></noscript>
                        </template:addResources>
                        <a href="#" id="hideThreads" class="hide" onclick="loadDisqus(jQuery(this),shortname, '${boundComponent.identifier}', window.location.href, '${fn:escapeXml(functions:abbreviate(functions:removeHtmlTags(boundComponent.displayableName), 20,40,'...'))}','${publicKey.string}')"><fmt:message key="jnt_disqusThread.hideComments"/></a>
                        <a id="showThreads" href="#" onclick="loadDisqus(jQuery(this),shortname, '${boundComponent.identifier}', window.location.href, '${fn:escapeXml(functions:abbreviate(functions:removeHtmlTags(boundComponent.displayableName), 20,40,'...'))}','${publicKey.string}');"><fmt:message key="jnt_disqusThread.showComments"/></a>
                    </div>
                </c:otherwise>
            </c:choose>
        </c:if>
    </c:otherwise>
</c:choose>