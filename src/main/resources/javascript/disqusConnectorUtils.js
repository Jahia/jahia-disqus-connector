/**
 * This function check the live properties and clear the interval if the live is up to date
 * @param getURL : This is the get URL to give to the checkLive function for its api call
 * @param inputShortname : This is the new value of the shortname propertie
 * @param inputPublicKey : This is the new value of the publicKey propertie
 * */
function waitForLive() {
    var onLive = checkLive();
    if (onLive) {
        clearInterval(intervalValue);
    }
}

/**
 * This function makes an api call to check if the properties in live mode are updated
 * @param url : The api call URL
 * @param inputShortname : This is the new value of the shortname property
 * @param inputPublicKey : This is the new value of the publicKey property
 * */
function checkLive() {
    $.ajax({
        type: "GET",
        url: readUrl,
        async: false,
        success: function (result) {
            return ($('#disqusShortnameField').val() == result.properties.shortname.value) && ($('#disqusPublicKeyField').val() == result.properties.publicKey.value);
        }
    });
    return false;
}

/**
 * This function create or update disqus settings JCR nodes with the shortname and public key from the form
 * */
function createUpdateDisqusParameters(intervalValue) {
    //getting the good Json form
    var jsonData;
    if (mode == 'create') {
        jsonData = "{\"children\":{\"disqusSettings\":{\"name\":\"disqusSettings\",\"type\":\"jnt:disqusConnector\",\"properties\":{\"shortname\":{\"value\":\"" + $('#disqusShortnameField').val() + "\"}, \"publicKey\":{\"value\":\"" + $('#disqusPublicKeyField').val() + "\"}}}}}";
    }
    else {
        jsonData = "{\"properties\":{\"shortname\":{\"value\":\"" + $('#disqusShortnameField').val() + "\"},\"publicKey\":{\"value\":\"" + $('#disqusPublicKeyField').val() + "\"}}}";
    }

    //Calling API to update JCR
    $.ajax({
        contentType: 'application/json',
        data: jsonData,
        dataType: 'json',
        processData: false,
        async: false,
        type: 'PUT',
        url: writeUrl,
        success: function (result) {
            //check live values every 0.5 sec untill they are up to date
            intervalValue = setInterval(waitForLive(), 500);
            window.location.reload();
        }
    });
}

function resetDisqusSettings() {
    $('#disqusShortnameField').val(jcrShortname);
    $('#disqusPublicKeyField').val(jcrPublickey);
    $('#saveDisqusSettings').attr("disabled", "disabled");
    $('#cancelChangeDisqusSettings').attr("disabled", "disabled");
}

/**
 * This function checks the shortname and public key inputs.
 * If they are well setup, it calls Disqus API to get the threads linked to the site to load the datatable
 * @param shortnameInput : The JCR shortname value
 * @param public_keyInput : The JCR publicKey value
 */
function loadDataTable() {
    var tableRows = '';//Datatable inner html

    //Calling Disqus API to get the threads
    var url = 'https://disqus.com/api/3.0/threads/list.json?forum=' + jcrShortname + '&api_key=' + jcrPublickey;
    var http = $.get(url,function (data) {
        //Generating datatable innerHTML from API response JSON
        threads = data.response;
        //Browsing the threads table
        var threadIndex = 0;
        for (threadIndex = 0; threadIndex < threads.length; threadIndex++) {
            //Setting the date locale
            moment.lang(locale);
            //Formatting the status display
            var threadStatus = threads[threadIndex].isClosed ? jsVarMap.statusClosed : jsVarMap.statusOpen;
            //Datatable Row inner HTML corresponding to the current thread
            var htmlTableLine = '<tr><td><a href="' + threads[threadIndex].link + '" target="_blank">' + threads[threadIndex].title + '</a></td><td> ' + threads[threadIndex].posts + ' </td><td>' + moment(new Date(threads[threadIndex].createdAt)).format("L") + '</td><td>' + threads[threadIndex].likes + '</td><td>' + threads[threadIndex].dislikes + '</td><td>' + threadStatus + '</td></tr>';
            //Adding the row to the datatable inner HTML
            tableRows = tableRows + htmlTableLine;
        }
        //Applying the innerHTML to the datatable
        $('#tableBody').html(tableRows);
        //Build Datatable
        $('#disqusThreads_table').dataTable({
            'sDom': "<'row-fluid'<'span6'l><'span6'f>r>t<'row-fluid'<'span6'i><'span6'p>>",
            'iDisplayLength': 25,
            'sPaginationType': 'bootstrap',
            'aaSorting': [], //this option disable sort by default, the user steal can use column names to sort the table
            'oLanguage': {
                'sEmptyTable': jsVarMap.emptyTable
            }
        });
        $('#datatableErrorMessage').hide();
        $('#dataTableDiv').show();
    }).fail(function (data) {
        if (data.status == 0) {
            $('#datatableErrorMessage').html(jsVarMap.errorPublicKey);
            $('#datatableErrorMessage').show();
            $('#dataTableDiv').hide();
        }
        else {
            $('#datatableErrorMessage').html(data.responseJSON.response);
            $('#datatableErrorMessage').show();
            $('#dataTableDiv').hide();
        }
        //Applying the innerHTML to the datatable
        $('#tableBody').html(tableRows);
    });
}