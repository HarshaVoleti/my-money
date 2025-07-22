enum InvestmentType {
  stocks,
  mutualFunds,
  bonds,
  etf,
  crypto,
  realEstate,
  gold,
  commodities,
  other;

  String get displayName {
    switch (this) {
      case InvestmentType.stocks:
        return 'Stocks';
      case InvestmentType.mutualFunds:
        return 'Mutual Funds';
      case InvestmentType.bonds:
        return 'Bonds';
      case InvestmentType.etf:
        return 'ETF';
      case InvestmentType.crypto:
        return 'Cryptocurrency';
      case InvestmentType.realEstate:
        return 'Real Estate';
      case InvestmentType.gold:
        return 'Gold';
      case InvestmentType.commodities:
        return 'Commodities';
      case InvestmentType.other:
        return 'Other';
    }
  }
}

enum DepositType {
  fixedDeposit,
  recurringDeposit,
  savingsAccount,
  currentAccount,
  ppf,
  nsc,
  other;

  String get displayName {
    switch (this) {
      case DepositType.fixedDeposit:
        return 'Fixed Deposit (FD)';
      case DepositType.recurringDeposit:
        return 'Recurring Deposit (RD)';
      case DepositType.savingsAccount:
        return 'Savings Account';
      case DepositType.currentAccount:
        return 'Current Account';
      case DepositType.ppf:
        return 'Public Provident Fund (PPF)';
      case DepositType.nsc:
        return 'National Savings Certificate (NSC)';
      case DepositType.other:
        return 'Other';
    }
  }
}

enum InvestmentStatus {
  active,
  sold,
  watchlist,
  suspended;

  String get displayName {
    switch (this) {
      case InvestmentStatus.active:
        return 'Active';
      case InvestmentStatus.sold:
        return 'Sold';
      case InvestmentStatus.watchlist:
        return 'Watchlist';
      case InvestmentStatus.suspended:
        return 'Suspended';
    }
  }
}

enum DepositStatus {
  active,
  matured,
  prematureClosed,
  suspended;

  String get displayName {
    switch (this) {
      case DepositStatus.active:
        return 'Active';
      case DepositStatus.matured:
        return 'Matured';
      case DepositStatus.prematureClosed:
        return 'Premature Closed';
      case DepositStatus.suspended:
        return 'Suspended';
    }
  }
}
