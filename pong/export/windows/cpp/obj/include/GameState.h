#ifndef INCLUDED_GameState
#define INCLUDED_GameState

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

HX_DECLARE_CLASS0(GameState)


class GameState_obj : public hx::EnumBase_obj
{
	typedef hx::EnumBase_obj super;
		typedef GameState_obj OBJ_;

	public:
		GameState_obj() {};
		HX_DO_ENUM_RTTI;
		static void __boot();
		static void __register();
		::String GetEnumName( ) const { return HX_CSTRING("GameState"); }
		::String __ToString() const { return HX_CSTRING("GameState.") + tag; }

		static ::GameState Paused;
		static inline ::GameState Paused_dyn() { return Paused; }
		static ::GameState Playing;
		static inline ::GameState Playing_dyn() { return Playing; }
};


#endif /* INCLUDED_GameState */ 
