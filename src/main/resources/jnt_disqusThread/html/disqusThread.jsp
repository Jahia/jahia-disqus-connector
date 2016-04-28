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

<template:addResources type="javascript" resources="disqusThreadUtils.js"/>
<template:addResources type="css" resources="disqus.css"/>

<jcr:node var="disqusNode" path="${renderContext.site.path}/disqusSettings" />
<c:set var="disqus_shortname" value="${disqusNode.properties['shortname'].string}"/>
<c:set var="boundComponent" value="${uiComponents:getBindedComponent(currentNode, renderContext, 'j:bindedComponent')}"/>

<template:addResources>
    <script type="text/javascript">
        /* * * DISQUS CONFIGURATION VARIABLES * * */
        <%@include file="disqusVariables.jspf"%>
    </script>
</template:addResources>

<c:choose>
    <c:when test="${empty disqus_shortname}">
        <c:if test="${renderContext.editMode}">
            <div class="disqusCommentsBlock" id="${boundComponent.identifier}" style="margin-bottom:15px;">
                <fmt:message key="jnt_disqusConnector.setParameters"/> <a href="<c:url value='${url.baseEdit}${renderContext.site.path}.disqusConnector.html'/>"> <span><fmt:message key="jnt_disqusConnector.here"/></span></a> <fmt:message
                    key="jnt_disqusConnector.toDisplay"/>
            </div>
        </c:if>
    </c:when>
    <c:otherwise>
        <c:if test="${not empty boundComponent}">
            <c:choose>
                <c:when test="${renderContext.editMode}">
                    <%@include file="../../jnt_disqusConnector/html/disqus.loader.jspf" %>
                    <div style="margin-top:5px;text-align: center"><fmt:message
                            key="jnt_disqusThread.threadWillBeDisplayed"/></div>
                </c:when>
                <c:otherwise>
                    <div id="disqus_thread"></div>
                    <script type="text/javascript">
                        getDisqus();
                    </script>
                    <a href="http://disqus.com" class="dsq-brlink">comments powered by <span
                            class="logo-disqus">Disqus</span></a>
                </c:otherwise>
            </c:choose>
        </c:if>
    </c:otherwise>
</c:choose>