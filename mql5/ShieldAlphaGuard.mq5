#property strict
#include <Trade/Trade.mqh>

input bool   EnableOrders = false;
input double RiskFraction = 0.0025;
input int    MaxSpreadPts = 25;
input ulong  Magic        = 560015;
input int    SlippagePts  = 10;

CTrade trade;
bool HaltNewOrders = true;

int OnInit() {
   trade.SetExpertMagicNumber(Magic);
   trade.SetDeviationInPoints(SlippagePts);
   return INIT_SUCCEEDED;
}

bool SignalSeen(const string signalId) {
   for (int i = OrdersTotal() - 1; i >= 0; --i) {
      ulong ticket = OrderGetTicket(i);
      if (ticket == 0) continue;
      if (OrderGetInteger(ORDER_MAGIC) == (long)Magic &&
          StringFind(OrderGetString(ORDER_COMMENT), signalId) >= 0)
         return true;
   }
   for (int i = PositionsTotal() - 1; i >= 0; --i) {
      ulong ticket = PositionGetTicket(i);
      if (ticket == 0) continue;
      if (PositionGetInteger(POSITION_MAGIC) == (long)Magic &&
          StringFind(PositionGetString(POSITION_COMMENT), signalId) >= 0)
         return true;
   }
   return false;
}

void OnTick() {
   if (HaltNewOrders || !EnableOrders) return;
   if (!TerminalInfoInteger(TERMINAL_CONNECTED)) return;
   if (!AccountInfoInteger(ACCOUNT_TRADE_ALLOWED)) return;
   long spread = SymbolInfoInteger(_Symbol, SYMBOL_SPREAD);
   if (spread < 0 || spread > MaxSpreadPts) return;
   // Size once from RiskFraction. Never increase it after a loss.
   // Refuse the send when SignalSeen(signalId) is true.
}
