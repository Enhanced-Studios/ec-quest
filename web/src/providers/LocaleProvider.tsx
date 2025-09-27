import { Context, createContext, useContext, useEffect, useState } from 'react';
import { useNuiEvent } from '../hooks/useNuiEvent';
import { debugData } from '../utils/debugData';
import { fetchNui } from '../utils/fetchNui';

interface Locale {
  ui_title_quest: string;
  ui_quest_claimed: string;
  ui_quest_claim: string;
  ui_quest_noQuest: string;
  ui_quest_noItems: string;
  ui_leaderboard_level: string;
  ui_leaderboard_player: string;
  ui_leaderboard_xp: string;
}

debugData(
  [
    {
      action: 'setLocale',
      data: {
        ui_title_quest: 'Quest Menu',
        ui_quest_claimed: 'Completed',
        ui_quest_claim: 'Complete',
        ui_quest_noQuest: 'No quests available',
        ui_quest_noItems: 'No items required',
        ui_leaderboard_level: 'Level',
        ui_leaderboard_player: 'Player',
        ui_leaderboard_xp: 'XP',
      },
    },
  ],
  2000
);

interface LocaleContextValue {
  locale: Locale;
  setLocale: (locales: Locale) => void;
}

const LocaleCtx = createContext<LocaleContextValue | null>(null);

const LocaleProvider: React.FC<{ children: React.ReactNode }> = ({ children }) => {
  const [locale, setLocale] = useState<Locale>({
    ui_title_quest: '',
    ui_quest_claimed: '',
    ui_quest_claim: '',
    ui_quest_noQuest: '',
    ui_quest_noItems: '',
    ui_leaderboard_level: '',
    ui_leaderboard_player: '',
    ui_leaderboard_xp: '',
  });

  useEffect(() => {
    fetchNui('loadLocale');
  }, []);

  useNuiEvent('setLocale', async (data: Locale) => setLocale(data));

  return <LocaleCtx.Provider value={{ locale, setLocale }}>{children}</LocaleCtx.Provider>;
};

export default LocaleProvider;

export const useLocales = () =>
  useContext<LocaleContextValue>(LocaleCtx as Context<LocaleContextValue>);
