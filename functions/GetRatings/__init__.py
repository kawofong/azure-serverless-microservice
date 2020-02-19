import json, logging

import azure.functions as func


def main(req: func.HttpRequest,
         cosmosDbDoc: func.DocumentList) -> func.HttpResponse:
    logging.info('Python HTTP trigger function "GetRating" processed a request.')

    if not cosmosDbDoc:
        return func.HttpResponse(
             'Please pass valid userId in query string',
             status_code=400
        )

    list_docs = []
    for doc in cosmosDbDoc:
        list_docs.append(json.loads(doc.to_json()))

    # Return review document from Azure Cosmos DB as HTTP response
    return func.HttpResponse(
        json.dumps(list_docs),
        headers={
            'Content-type': 'application/json'
        })
