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
<%--@elvariable id="out" type="java.io.PrintWriter"--%>
<%--@elvariable id="renderContext" type="org.jahia.services.render.RenderContext"--%>
<%--@elvariable id="script" type="org.jahia.services.render.scripting.Script"--%>
<%--@elvariable id="scriptInfo" type="java.lang.String"--%>
<%--@elvariable id="url" type="org.jahia.services.render.URLGenerator"--%>
<%--@elvariable id="workspace" type="java.lang.String"--%>
<template:addResources type="css" resources="admin-bootstrap.css,datatables/css/bootstrap-theme.css,tablecloth.css"/>
<%--<template:addResources type="javascript" resources="jquery.min.js,admin-bootstrap.js,workInProgress.js"/>--%>
<template:addResources type="javascript" resources="datatables/jquery.dataTables.js,i18n/jquery.dataTables-${currentResource.locale}.js,datatables/dataTables.bootstrap-ext.js"/>
<template:addResources type="javascript" resources="moment.min.js"/>
<jcr:node var="disqusNode" path="${renderContext.site.path}/disqusSettings"/>
<jcr:nodeProperty var="shortname" node="${disqusNode}" name="shortname"/>
<jcr:nodeProperty var="publicKey" node="${disqusNode}" name="publicKey"/>
<jcr:node var="site" path="${renderContext.site.path}"/>

<template:addResources>
    <script type="text/javascript">
        var context = "${url.context}";
        var API_URL_START = "modules/api/jcr/v1";
        var locale = "${renderContext.UILocale}";
        var jcrShortname = "${shortname.string}";
        var jcrPublickey = "${publicKey.string}";
        var mode;
        var endOfURI;
        var threads;
        <c:choose>
            <c:when test="${empty disqusNode}">
                mode = 'create';
                endOfURI = '${site.identifier}';
                console.log("Mode Create");
            </c:when>
            <c:otherwise>
                mode = 'update';
                endOfURI = '${disqusNode.identifier}';
                console.log("Mode Update");
            </c:otherwise>
        </c:choose>

        /**
         * This function check the live properties and clear the interval if the live is up to date
         * @param getURL : This is the get URL to give to the checkLive function for its api call
         * @param inputShortname : This is the new value of the shortname propertie
         * @param inputPublicKey : This is the new value of the publicKey propertie
         * */
        function waitForLive(getURL, inputShortname, inputPublicKey){
            var onLive = checkLive(getURL, inputShortname, inputPublicKey);
            if(onLive)
            {
                clearInterval();
            }
        }

        /**
         * This function makes an api call to check if the properties is live mode are updated
         * @param url : The api call URL
         * @param inputShortname : This is the new value of the shortname propertie
         * @param inputPublicKey : TThis is the new value of the publicKey propertie
         * */
        function checkLive(url, inputShortname, inputPublicKey)
        {
            $.ajax({
                type:"GET",
                url: url,
                async: false,
                success:function(result) {
                    return (inputShortname == result.properties.shortname.value) && (inputPublicKey==result.properties.publicKey.value);
                }
            });
            return false;
        }

        /**
         * This function create or update disqus settings JCR nodes with the shortname and public key from the form
         * @param shortnameInput
         * @param public_keyInput
         * */
        function createUpdateDisqusParameters(inputShortname,inputPublicKey, endOfURI)
        {
            var writeUrl = context+"/"+API_URL_START+"/default/"+locale+"/nodes/"+endOfURI;
            var readUrl = context+"/"+API_URL_START+"/live/"+locale+"/paths${renderContext.site.path}/disqusSettings";
            var jsonData;

            //getting the good Json form
            if(mode == 'create')
            {
                jsonData = "{\"children\":{\"disqusSettings\":{\"name\":\"disqusSettings\",\"type\":\"jnt:disqusConnector\",\"properties\":{\"shortname\":{\"value\":\""+shortname+"\"}, \"publicKey\":{\"value\":\""+api_key+"\"}}}}}";
            }
            else
            {
                jsonData = "{\"properties\":{\"shortname\":{\"value\":\""+inputShortname+"\"},\"publicKey\":{\"value\":\""+inputPublicKey+"\"}}}";
            }

            //Calling API to update JCR
            $.ajax({
                contentType: 'application/json',
                data: jsonData,
                dataType: 'json',
                processData: false,
                type: 'PUT',
                url: writeUrl,
                success:function(result) {
                    //check live values every 0.5 sec untill they are up to date
                    setInterval(waitForLive(readUrl, inputShortname, inputPublicKey),500);
                    return true;
                },
                error : function(result){
                    //check live values every 0.5 sec untill they are up to date
                    setInterval(function(){
                        console.log("In interval ...");
                        waitForLive(readUrl, inputShortname, inputPublicKey);
                    },500);
                    return false;
                }
            });
        }

        /**
        * This function checks the shortname and public key inputs.
        * If they are well setup, it calls Disqus API to get the threads linked to the site to load the datatable
        * @param shortnameInput : The JCR shortname value
        * @param public_keyInput : The JCR publicKey value
        */
        function loadDataTable(disqusJcrShortname,disqusJcrPublicKey)
        {
            var tableRows = "";//Datatable inner html
            if(!disqusJcrShortname || !disqusJcrPublicKey)
            {
                //If shortname and public key are not both setup Jahia is not able to get thread list
                tableRows = '<tr><td colspan="100%" style="text-align: center"><fmt:message key="jnt_disqusConnector.noSettings"/></td></tr>';
                //Applying the innerHTML to the datatable
                $("#tableBody").html(tableRows);
            }
            else
            {
                //Calling Disqus API to get the threads
                var url = "https://disqus.com/api/3.0/threads/list.json?forum="+disqusJcrShortname+"&api_key="+disqusJcrPublicKey;
                var http = $.get(url,function(data) {
                    //Generating datatable innerHTML from API response JSON
                    threads = data.response;
                    if(threads.length == 0)
                    {//No threads to display
                        tableRows = '<tr><td colspan="100%" style="text-align: center"><fmt:message key="jnt_disqusConnector.empty.table"/></td></tr>';
                    }
                    else
                    {//Browsing the threads table
                        var threadIndex=0;
                        for(threadIndex=0;threadIndex<threads.length;threadIndex++)
                        {
                            //Setting the date locale
                            moment.lang("${currentResource.locale}");
                            //Formatting the status display
                            var threadStatus = threads[threadIndex].isClosed?'<span class="text-error"><strong><fmt:message key="jnt_disqusConnector.status.closed"/></strong></span>':'<span class="text-success"><strong><fmt:message key="jnt_disqusConnector.status.open"/></strong></span>';
                            //Datatable Row inner HTML corresponding to the current thread
                            var htmlTableLine = '<tr><td><a href="'+threads[threadIndex].link+'">'+threads[threadIndex].title+'</a></td><td>'+moment(new Date(threads[threadIndex].createdAt)).format("L")+'</td><td>'+threads[threadIndex].likes+'</td><td>'+threads[threadIndex].dislikes+'</td><td>'+threadStatus+'</td></tr>';
                            //Adding the row to the datatable inner HTML
                            tableRows = tableRows+htmlTableLine;
                        }
                    }
                    //Applying the innerHTML to the datatable
                    $("#tableBody").html(tableRows);
                }).fail(function(data){
                    if(data.status==0)
                    {
                        tableRows = '<tr><td colspan="100%" style="text-align: center"><fmt:message key="jnt_disqusConnector.wrongPublicKey"/></td></tr>';
                    }
                    else
                    {
                        tableRows = '<tr><td colspan="100%" style="text-align: center">'+data.responseJSON.response+'</td></tr>';
                    }
                    //Applying the innerHTML to the datatable
                    $("#tableBody").html(tableRows);
                })
            }
        }

        $(document).ready(function () {
            //load datatable with the list of disqus threads calling disqus API
            loadDataTable(jcrShortname,jcrPublickey);
            //Build Datatable
            $('#disqusThreads_table').dataTable({
                "sDom": "<'row-fluid'<'span6'l><'span6'f>r>t<'row-fluid'<'span6'i><'span6'p>>",
                "iDisplayLength":25,
                "sPaginationType": "bootstrap",
                "aaSorting": [] //this option disable sort by default, the user steal can use column names to sort the table
            });

        });
    </script>
</template:addResources>
<div class="container">
    <div style="text-align:center"><h1> <fmt:message key="jnt_disqusConnector"/></h1></div>

    <h3> <fmt:message key="jnt_disqusConnector.accountInformation"/></h3>
    <div class="row-fluid">
        <form name="disqusParameter" onsubmit="createUpdateDisqusParameters(shortnameInput, public_keyInput,endOfURI)">
            <div class="alert alert-info">
                <div class="row-fluid">
                    <div class="span6">
                        <div id="disqusInfo" class=".col-md-6 .col-md-offset-3">
                            <div class="control-group">
                                <label class="control-label"><fmt:message key="jnt_disqusConnector.shortname"/></label>
                                <div class="controls">
                                    <input id="disqusShortnameField" name="shortname" type="text" value="<c:if test="${!empty shortname}">${shortname.string}</c:if>" onblur="console.log('shortname input : '+$(this).val());shortnameInput=$(this).val();"/>
                                </div>
                            </div>
                            <div class="control-group">
                                <label class="control-label"><fmt:message key="jnt_disqusConnector.publicKey"/></label>
                                <div class="controls">
                                    <input id="disqusApiKeyField" name="publicKey" type="text" value="<c:if test="${!empty publicKey}">${publicKey.string}</c:if>" onblur="public_keyInput=$(this).val();"/>
                                </div>
                            </div>
                            <div>
                                <input type="submit" class="btn btn-success"  value="<fmt:message key="save"/>">
                            </div>
                        </div>
                    </div>
                    <div class="span6" style="text-align:justify">
                        <h6><fmt:message key="jnt_disqusConnector.shortname"/></h6>
                        <p>
                            <fmt:message key="jnt_disqusConnector.help.getShortname"/>
                            <fmt:message key="jnt_disqusConnector.help.getShortname2"/>
                            <fmt:message key="jnt_disqusConnector.help.getShortname3"/>
                        </p>
                        <h6><fmt:message key="jnt_disqusConnector.publicKey"/></h6>
                        <p>
                            <fmt:message key="jnt_disqusConnector.help.getPublicKey"/>
                            <fmt:message key="jnt_disqusConnector.help.getPublicKey2"/>
                            <fmt:message key="jnt_disqusConnector.help.getPublicKey3"/> : <br/>
                            <a href="https://disqus.com/api/applications/"><fmt:message key="jnt_disqusConnector.help.applicationURL"/></a>

                        </p>
                    </div>
                </div>
                <div class="clearfix"></div>
            </div>
        </form>
    </div>
    <h3> <fmt:message key="jnt_disqusConnector.displayThreadsTitle"/></h3>
    <fieldset>
        <table cellpadding="0" cellspacing="0" border="0" class="table table-striped table-bordered" id="disqusThreads_table">
            <thead>
                <tr>
                    <th><fmt:message key="jnt_disqusConnector.threadTitle"/></th>
                    <th><fmt:message key="jnt_disqusConnector.creationDate"/></th>
                    <th><fmt:message key="jnt_disqusConnector.likes"/></th>
                    <th><fmt:message key="jnt_disqusConnector.dislikes"/></th>
                    <th><fmt:message key="jnt_disqusConnector.status"/></th>
                </tr>
            </thead>
            <tbody id="tableBody">
                <tr><td colspan="100%" style="text-align: center"><%@include file="disqus.loader.jspf" %></td></tr>
            </tbody>
        </table>
    </fieldset>

</div>