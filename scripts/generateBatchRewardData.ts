import { BigQuery } from "@google-cloud/bigquery"
import { getFeeDistributorsFromLogs } from "./getFeeDistributorsFromLogs"
import { getFirstValidatorIdAndValidatorCount } from "./getFirstValidatorIdAndValidatorCount"

export async function generateBatchRewardData(feeDistributorFactoryAddress: string) {
    const feeDistributorAddresses = await getFeeDistributorsFromLogs(feeDistributorFactoryAddress)
    const getFirstValidatorIdAndValidatorCountPromises = feeDistributorAddresses.map(getFirstValidatorIdAndValidatorCount)
    const idsAndCounts = await Promise.all(getFirstValidatorIdAndValidatorCountPromises)
    const valIdsGrouped = idsAndCounts.map(range)
    const valIds = flatten(valIdsGrouped)
    const rows = await getRowsFromBigQuery(valIds)

    const groupedSums = groupAndSum(rows, idsAndCounts);
    return groupedSums;
}

export function groupAndSum(
    rows: {val_id: number, val_amount: number}[],
    idsAndCounts: {firstValidatorId: number, validatorCount: number}[]
) {
    return idsAndCounts.map(({ firstValidatorId, validatorCount }) => {
        const rangeIds = range({ firstValidatorId, validatorCount });
        const sum = rows
            .filter(row => rangeIds.includes(row.val_id))
            .reduce((accumulator, row) => accumulator + row.val_amount, 0);
        return [firstValidatorId, validatorCount, sum];
    });
}

const isGoerli = false

export async function getRowsFromBigQuery(valIds: number[]) {
    const bigquery = new BigQuery()

    const query = `
        with chunk as (
    select epoch, val_id,
           epoch_date,
           val_balance_withdrawn,
           att_earned_reward,
           propose_earned_reward,
           sync_earned_reward,
           att_penalty,
           propose_penalty,
           sync_penalty
    from \`p2p-data-warehouse.raw_ethereum.${isGoerli ? 'testnet_' : ''}validators_summary\`
    where 1=1
      and val_slashed != 1
        and val_id IN (${valIds}) 
            ${isGoerli ? '' : 'and epoch_date >= "2023-07-11"'}
),


withdrawals_epochs as (SELECT epoch,
                              val_id,
                              ROW_NUMBER() over (partition by val_id order by epoch) as withdrawal_number
                        FROM chunk
                        where val_balance_withdrawn is not null
                       ),

withdrawal_periods as (select chunk.epoch,
                              chunk.val_id,
                              chunk.epoch_date,
                              val_balance_withdrawn,
                              COALESCE(att_earned_reward, 0) +
                              COALESCE(propose_earned_reward, 0) +
                              COALESCE(sync_earned_reward, 0) -
                              COALESCE(att_penalty, 0) -
                              COALESCE(propose_penalty, 0) -
                              COALESCE(sync_penalty, 0) as earned_rewards,
                              we.withdrawal_number,
                              COALESCE(
                                      we.withdrawal_number,
                                      LAST_VALUE(we.withdrawal_number ignore nulls)
                                                 OVER (partition by chunk.val_id ORDER BY chunk.epoch rows between unbounded preceding and current row) +
                                      1,
                                      1
                                  )                     AS withdrawal_period
                       FROM chunk
                                left join withdrawals_epochs we on we.epoch = chunk.epoch and we.val_id = chunk.val_id)


select val_id,
       sum(amount) as val_amount
from (
select val_id, withdrawal_period,
       sum(mod(val_balance_withdrawn, cast(32*power(10,9) as int))) as withdrawn_rewards,
       case when sum(mod(val_balance_withdrawn, cast(32*power(10,9) as int))) - sum(earned_rewards) < sum(earned_rewards)
            then sum(mod(val_balance_withdrawn, cast(32*power(10,9) as int)))
            else sum(earned_rewards) end as amount
from withdrawal_periods
group by val_id, withdrawal_period)
where withdrawn_rewards is not null
group by val_id
    `

    const [job] = await bigquery.createQueryJob({
        query: query,
        location: "US"
    })
    const [rows] = await job.getQueryResults()
    return rows
}

export function range({firstValidatorId, validatorCount}: {firstValidatorId: number, validatorCount: number}) {
    return [...Array(validatorCount).keys()].map(i => i + firstValidatorId);
}

export function flatten(array: number[][]) {
    return array.reduce((accumulator, currentValue) => accumulator.concat(currentValue), []);
}
