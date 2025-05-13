import {BigQuery} from "@google-cloud/bigquery";
import { logger } from "./logger"

export async function getValidatorIndexesFromBigQuery(val_ids: number[]): Promise<{val_id: number, val_pubkey: string}[]> {
    logger.info('Getting indexes from BigQuery for ' + val_ids.length + ' pubkeys')

    const isGoerli = false

    const bigquery = new BigQuery()

    const query = `
        SELECT val_id, val_pubkey FROM \`p2p-data-warehouse.raw_ethereum.${isGoerli ? 'testnet_' : ''}validators_index\`
        WHERE val_id IN (${"'" + val_ids.join("','") + "'"})
    `

    const [job] = await bigquery.createQueryJob({
        query: query,
        location: "US"
    })
    const [rows] = await job.getQueryResults()

    logger.info('Indexes from BigQuery fetched for ' + rows.length + ' pubkeys')

    return rows
}
