import { getLegacyClientOnlyClRewardsOne } from "./getLegacyClientOnlyClRewardsOne"

const fds = [
    {oracleId: 1, feeDivider: '0x05660a51A688E9F102f0bF46Cb6e64efc3381408'},
    {oracleId: 2, feeDivider: '0xB21E436D4deA46adbB3F5276d357180e694dC8b7'},

    {oracleId: 4, feeDivider: '0x0216CfF879B17B5beDe762B3e4071B49c8696a25'},
    {oracleId: 5, feeDivider: '0x3d1be477186D64B4f4fba7cB773216dA0C2B474F'},
    {oracleId: 6, feeDivider: '0xBB52D5B7F2AE4BBe0967F4626d07aba89F462Ff7'},
    {oracleId: 7, feeDivider: '0x36c0A9B9D3799bddbcED6f584a70060DF368a073'},

    {oracleId: 8, feeDivider: '0xF555a33C07eEAB91EE4bF1Bc950c14Fc8a9EF1aB'},
    {oracleId: 9, feeDivider: '0xe39640588571F507298F688bf8b1F68D9600F96c'},
    {oracleId: 10, feeDivider: '0xd6781E7F15752d3F5764609a42A803A7345DE25c'},

    {oracleId: 11, feeDivider: '0xD3825cd251eF9AD7b9Bffec5851e438e15D0a358'},
    {oracleId: 12, feeDivider: '0x72288Ee8c6304778D5d78AaB71F50acAC61E7B81'},
]

export async function getLegacyClientOnlyClRewards() {
    const fdsWithLegacyClientOnlyClRewards: {oracleId: number, feeDivider: string, legacyClientOnlyClRewards: number}[] = []

    for (const fd of fds) {
        const legacyClientOnlyClRewards = await getLegacyClientOnlyClRewardsOne(fd.feeDivider)

        fdsWithLegacyClientOnlyClRewards.push(
            {...fd, legacyClientOnlyClRewards}
        )
    }

    return fdsWithLegacyClientOnlyClRewards
}
