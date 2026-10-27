#!/usr/bin/env python3
"""Risk Guardian. No other agent may override a veto."""

from dataclasses import dataclass


@dataclass(frozen=True)
class Limits:
    risk_per_trade: float = 0.0025
    daily_loss: float = 0.01
    weekly_loss: float = 0.03
    max_drawdown: float = 0.05


def decide(equity, peak, day_pnl, week_pnl, risk_cash,
           feed_ok, spread_known, news_block, calibrated, live_armed):
    reasons = []
    if not feed_ok:
        reasons.append("feed_down")
    if not spread_known:
        reasons.append("cost_unverified")
    if news_block:
        reasons.append("news_blackout")
    if not calibrated:
        reasons.append("model_not_validated")
    if peak > 0 and (peak - equity) / peak >= Limits.max_drawdown:
        reasons.append("max_drawdown")
    if equity > 0 and day_pnl <= -Limits.daily_loss * equity:
        reasons.append("daily_loss")
    if equity > 0 and week_pnl <= -Limits.weekly_loss * equity:
        reasons.append("weekly_loss")
    if equity <= 0 or risk_cash > Limits.risk_per_trade * equity + 1e-9:
        reasons.append("risk_per_trade_or_unknown_equity")
    if reasons:
        return "REJECTED", reasons
    if not live_armed:
        return "PAPER_ONLY", ["live_locked"]
    return "ELIGIBLE", []


if __name__ == "__main__":
    status, reasons = decide(
        equity=0, peak=0, day_pnl=0, week_pnl=0, risk_cash=0,
        feed_ok=False, spread_known=False, news_block=True,
        calibrated=False, live_armed=False,
    )
    print(status)
    print(",".join(reasons))
