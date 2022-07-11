import { useNuiEvent } from '@libs/nui/hooks/useNuiEvent';
import { PhoneEvents } from '@typings/phone';
import React, { PropsWithChildren, useState } from 'react';
import { RecoilRoot } from 'recoil';

// Because how both recoil functions and how our store works, we need
// to use *somewhat* of a hack for resetting the global state. In this case,
// we just increment a counter every time we change characters in order to force
// a refresh
// This is liable to memory leaky behavior in extreme cases.

export const RecoilRootManager: React.FC<PropsWithChildren> = ({ children }) => {
    const [charState, setCharState] = useState(0);

    useNuiEvent('PHONE', PhoneEvents.UNLOAD_CHARACTER, () => {
        setCharState(charState => charState + 1);
    });

    return <RecoilRoot key={charState}>{children}</RecoilRoot>;
};