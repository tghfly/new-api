/*
Copyright (C) 2025 QuantumNous

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU Affero General Public License as
published by the Free Software Foundation, either version 3 of the
License, or (at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
GNU Affero General Public License for more details.

You should have received a copy of the GNU Affero General Public License
along with this program. If not, see <https://www.gnu.org/licenses/>.

For commercial licensing, please contact support@quantumnous.com
*/

export const initialState = {
  groupMap: {},
  loading: false,
  error: null,
};

export const actionTypes = {
  SET_GROUP_MAP: 'SET_GROUP_MAP',
  SET_LOADING: 'SET_LOADING',
  SET_ERROR: 'SET_ERROR',
  UPDATE_GROUP_MAP: 'UPDATE_GROUP_MAP',
};

export const reducer = (state, action) => {
  switch (action.type) {
    case actionTypes.SET_GROUP_MAP:
      return {
        ...state,
        groupMap: action.payload,
        loading: false,
        error: null,
      };
    case actionTypes.SET_LOADING:
      return {
        ...state,
        loading: action.payload,
      };
    case actionTypes.SET_ERROR:
      return {
        ...state,
        error: action.payload,
        loading: false,
      };
    case actionTypes.UPDATE_GROUP_MAP:
      return {
        ...state,
        groupMap: {
          ...state.groupMap,
          ...action.payload,
        },
      };
    default:
      return state;
  }
};