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
<c:set var="shortnameValue" value="${shortname.string}"/>
<c:if test="${!empty currentNode.properties['shortname'].string}">
    <c:set var="shortnameValue" value="${currentNode.properties['shortname'].string}"/>
</c:if>
<c:url var="disqusSettingsURL" value="${url.baseEdit}${renderContext.site.path}.disqusConnector.html"/>

<template:addResources>
    <script type="text/javascript">
        /* * * DISQUS CONFIGURATION VARIABLES * * */
        var disqus_shortname;
        var disqus_identifier = '${boundComponent.identifier}';
        var disqus_url = window.location.href;
        var disqus_title = '${fn:escapeXml(functions:abbreviate(functions:removeHtmlTags(boundComponent.displayableName), 20,40,'...'))}';

        var context = "${url.context}";
        var API_URL_START = "modules/api/jcr/v1";
        var locale = "${renderContext.UILocale}";
        var readUrl = context + "/" + API_URL_START + "/live/" + locale + "/paths${renderContext.site.path}/disqusSettings";
        var public_key;
        var shortname;
        <c:if test="${not empty disqusNode}">
        //Get shortname from settings node via Jahia API call
        $.get(readUrl, function (data) {
            shortname = data.properties.shortname.value;
            //Put shortname in the Disqus configuration variable
            disqus_shortname = shortname;
        });
        </c:if>
    </script>
</template:addResources>

<c:choose>
    <c:when test="${empty shortname.string}">
        <c:if test="${renderContext.editMode}">
            <div class="disqusCommentsBlock" id="${boundComponent.identifier}" style="margin-bottom:15px;">
                <fmt:message key="jnt_disqusConnector.setParameters"/> <a href="${disqusSettingsURL}"> <span
                    class="btn btn-primary"><fmt:message key="jnt_disqusConnector.here"/></span></a> <fmt:message
                    key="jnt_disqusConnector.toDisplay"/>
            </div>
        </c:if>
    </c:when>
    <c:otherwise>
        <c:if test="${not empty boundComponent}">
            <c:choose>
                <c:when test="${!renderContext.liveMode}">
                    <%@include file="../../jnt_disqusConnector/html/disqus.loader.jspf" %>
                    <div style="margin-top:5px;text-align: center"><fmt:message
                            key="jnt_disqusThread.threadWillBeDisplayed"/></div>
                </c:when>
                <c:otherwise>
                    <div id="disqus_thread"></div>
                    <script type="text/javascript">
                        /* * * DON'T EDIT BELOW THIS LINE * * */
                        (function () {
                            var dsq = document.createElement('script');
                            dsq.type = 'text/javascript';
                            dsq.async = true;
                            dsq.src = '//' + disqus_shortname + '.disqus.com/embed.js';
                            (document.getElementsByTagName('head')[0] || document.getElementsByTagName('body')[0]).appendChild(dsq);
                        })();
                    </script>
                    <a href="http://disqus.com" class="dsq-brlink">comments powered by <span
                            class="logo-disqus">Disqus</span></a>
                </c:otherwise>
            </c:choose>
        </c:if>
    </c:otherwise>
</c:choose>