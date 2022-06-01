QBShared = QBShared or {}

QBShared.Pollution = {}

QBShared.Pollution.Level = {
    Low = 1,
    Neutral = 2,
    High = 3
}

QBShared.Pollution.Threshold = {
    [QBShared.Pollution.Level.Low] = { min = 0, max = 11 },
    [QBShared.Pollution.Level.Neutral] = { min = 11, max = 70 },
    [QBShared.Pollution.Level.High] = { min = 70, max = 100 },
}

