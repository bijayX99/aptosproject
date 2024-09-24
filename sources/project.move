module MyModule::StakingPlatform {

    use aptos_framework::signer;
    use aptos_framework::coin;
    use aptos_framework::aptos_coin::AptosCoin;

    /// Struct representing the staked tokens and reward pool.
    struct StakingPool has store, key {
        total_staked: u64,
        reward_rate: u64, // Reward rate per staked token
    }

    /// Function to create a staking pool with a reward rate.
    public fun create_pool(owner: &signer, reward_rate: u64) {
        let pool = StakingPool {
            total_staked: 0,
            reward_rate,
        };
        move_to(owner, pool);
    }

    /// Function to stake tokens and receive rewards.
    public fun stake_tokens(staker: &signer, pool_owner: &signer, amount: u64) acquires StakingPool {
        let pool = borrow_global_mut<StakingPool>(signer::address_of(pool_owner));

        // Stake tokens
        let stake = coin::withdraw<AptosCoin>(staker, amount);
        coin::deposit<AptosCoin>(signer::address_of(pool_owner), stake);

        // Calculate rewards based on the reward rate
        let rewards = amount * pool.reward_rate;

        // Reward the staker by transferring tokens
        let reward_transfer = coin::withdraw<AptosCoin>(pool_owner, rewards);
        coin::deposit<AptosCoin>(signer::address_of(staker), reward_transfer);

        // Update the total staked tokens in the pool
        pool.total_staked = pool.total_staked + amount;
    }
}
