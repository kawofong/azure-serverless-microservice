import json, logging, uuid

import azure.functions as func


def main(event: func.EventHubEvent,
         cosmosDbDoc: func.Out[func.Document]):
    logging.info('Python HTTP trigger function "ProcessSalesEvents" processed a request.')

    # Decode event hub binary payload to JSON
    message = event.get_body().decode('utf-8')
    sale_events = json.loads(message)

    logging.info(f'Event Count: {len(sale_events)}')

    # Iterate through sales events and load each event in Azure Cosmos DB
    for sale_event in sale_events:
        newdoc = sale_event
        newdoc['id'] = str(uuid.uuid4())
        # logging.info(newdoc)
        cosmosDbDoc.set(func.Document.from_dict(newdoc))

        # output = json.dumps(newdoc)
        # # logging.warn(output)
        # cosmosDbDoc.set(func.Document.from_json(output))
