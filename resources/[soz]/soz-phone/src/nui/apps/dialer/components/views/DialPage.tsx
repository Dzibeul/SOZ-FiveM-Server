import { useQueryParams } from '@common/hooks/useQueryParams';
import React, { useState } from 'react';

import { DialInputCtx } from '../../context/InputContext';
import { DialerInput } from '../DialerInput';
import DialGrid from '../DialPadGrid';

const DialPage: React.FC = () => {
    const query = useQueryParams();
    const queryNumber = query.number;
    const [inputVal, setInputVal] = useState(queryNumber || '');

    return (
        <div>
            <DialInputCtx.Provider
                value={{
                    inputVal,
                    add: (val: string) => setInputVal(inputVal + val),
                    removeOne: () => setInputVal(inputVal.slice(0, -1)),
                    clear: () => setInputVal(''),
                    set: (val: string) => setInputVal(val),
                }}
            >
                <DialerInput />
                <DialGrid />
            </DialInputCtx.Provider>
        </div>
    );
};
export default DialPage;