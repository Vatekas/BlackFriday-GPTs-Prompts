Config = {}

-- Framework settings
-- 'auto' (detect automatically), 'esx', 'qb-core', or 'standalone'
Config.Framework = 'auto'

-- Default text for unemployed players
Config.JobLabelFallback = 'Ieškantis Darbo'

-- Time settings
Config.RealTime = true -- true = real system time (TODAY'S REAL TIME), false = in-game time
Config.TimeFormat = 24  -- 24 or 12 hour format

-- Money settings
Config.HideDirtyMoneyIfZero = true -- If true, the red dirty money pill is hidden when it is $0

-- Voice/Microphone settings
Config.VoiceLevels = 3 -- Number of voice levels (e.g., whisper, normal, shout)
Config.VoiceColors = {
    [1] = '#a0aec0', -- Whisper (gray/low range)
    [2] = '#3182ce', -- Normal (blue/medium range)
    [3] = '#e53e3e'  -- Shout (red/high range)
}
