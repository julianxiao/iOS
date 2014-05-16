#ifdef _WIN32
#include <windows.h>
#endif

#include "pbook.h"
#include "tree_utils.h"
#include "linear_system.h"



static int ROIIsProperSubsetOfPhoto ( struct config_params *cp, struct photo *ph, 
									  struct pixel_rectangle *ROI );
static int pixelRectIsProperSubsetOfPhoto ( struct config_params *cp, struct photo *ph, 
											int height, int width, int vert_offset,
											int horiz_offset );
static void verifyROIAndPhotoInfoAreValid ( struct config_params *cp, struct photo *ph, 
											struct pixel_rectangle *ROI );
static void generateGAListFromCFT ( struct config_params *cp, 
									struct graphic_assembly_list *GA_list,
									struct content_file_transcript *cft );
static struct fixed_dimensions_version_spec *fixedDimensionsVersionSpecFromGEID ( struct GE_identifier *GE_ID,
																				  struct graphic_assembly_spec *GA_spec );
static struct photo_spec *photoSpecFromGEID ( struct GE_identifier *GE_ID,
											  struct graphic_assembly_spec *GA_spec );
static void recordAreasFromGASpec ( struct page_schedule_entry *pse,
									struct graphic_assembly_spec *GA_spec );
static void assignAreaValuesToPhotoSpecs ( struct graphic_assembly_spec *GA_spec );
static void recordAreasFromContentFileTranscript ( struct page_schedule *pg_sched,
												   struct content_file_transcript *cft );
static void verifyGASpecsAndGAListLineUp ( struct content_file_transcript *cft,
										   struct graphic_assembly_list *GA_list );
static void recordAreasFromCollectionSchedule ( struct page_schedule *pg_sched,
												struct content_file_transcript *cft,
												struct graphic_assembly_list *GA_list );
static int aspectRatioBin ( double aspect );
static void generateAspectHistogram ( int *num_photo_GAs, 
									  int *aspect_label, int *max_hist_val, 
									  struct page_schedule *pg_sched,
									  struct graphic_assembly_list *GA_list );
static int numPhotoGEsInLayout ( struct layout *L, struct graphic_assembly_list *GA_list );
static int numPhotoGAsOnPage ( struct page_schedule *pg_sched,
							   struct graphic_assembly_list *GA_list );
static int numPhotoGEsOnPage ( struct page_schedule *pg_sched,
							   struct graphic_assembly_list *GA_list );
static void verifyGAIsInPageSchedule ( int GA_index, struct page_schedule *pg_sched );
static int numGESchedulesInPageSchedule ( struct page_schedule *pg_sched );
static int numPhotoGESchedulesInPageSchedule ( struct page_schedule *pg_sched,
											   struct graphic_assembly_list *GA_list );
static int numGAsInPageSchedule ( int GA_index, struct page_schedule *pg_sched );
static void verifyGAIsNotInPageSchedule ( int GA_index, struct page_schedule *pg_sched );
static int GAIsNotInPageSchedule ( int GA_index, struct page_schedule *pg_sched );
static int GAIsInPageSchedule ( int GA_index, struct page_schedule *pg_sched );
static void populatePageScheduleEntry ( struct graphic_assembly *GA,
										struct page_schedule_entry *pse );
static void addPageScheduleEntryToPageSchedule ( struct page_schedule_entry *incoming_pse, 
												 struct page_schedule *pg_sched );
static void checkPageSchedule ( struct page_schedule *pg_sched );
static void initAreaAspectHistogram ( struct twoD_double_array *area_aspect_hist,
									  int max_areas );
static void initTwoDIntegerArray ( struct twoD_integer_array *twoDIA, int num_integer_lists,
								   int integer_list_length );
static void initGAAspectHistogram ( struct twoD_integer_array *GA_aspect_hist, int max_GAs );
static void deleteTwoDIntegerArray ( struct twoD_integer_array *twoDIA );
static void deleteTwoDDoubleArray ( struct twoD_double_array *twoDDA );
static int numberIsInIntegerList ( struct integer_list *list, int number );
static int numberIsNotInIntegerList ( struct integer_list *list, int number );
static void verifyNumberIsNotInIntegerList ( struct integer_list *list, int number );
static void addNumToDoubleList ( struct double_list *list, double number,
									int position_index );
static void addNumToEndOfIntList ( struct integer_list *list, int number );
static void addNumToIntList ( struct integer_list *list, int number,
									 int position_index );
static void addGEIDToGEIDList ( struct GE_identifier_list *list, struct GE_identifier *GEID,
								int position_index );
static void jumbleIntegerList ( struct integer_list *list );
static void makeGAAspectHistogramFromPageSchedule ( struct page_schedule *pg_sched,
													struct graphic_assembly_list *GA_list, 
													struct twoD_integer_array *GA_aspect_hist );
static void makeInterleavedList ( struct page_schedule *pg_sched,
								  struct twoD_integer_array *GA_aspect_hist,
								  struct integer_list *list );
static int numberOfNonemptyIntegerArrays ( struct twoD_integer_array *twoDIA );
static void makeAltPageScheduleLists ( struct page_schedule *pg_sched, 
									   struct integer_list *interleaved_photo_GA_index_list,
									   struct integer_list *complete_GA_index_list,
  									   int *num_diff_aspects, 
									   struct graphic_assembly_list *GA_list );
static void recordAreasFromThinAir ( struct page_schedule *pg_sched, int GA_index,
									 struct graphic_assembly_list *GA_list, 
									 double relative_area );
static void checkAreaDistribution ( int num_GAs, int interleaved_list_len, 
									int num_big, int num_med, int num_small );
static void makeRandomAreaDist ( int num_photo_GAs, int num_GAs,
								 int *num_big, int *num_med, int *num_small );
static void generatePageSchedule ( struct page_schedule *pg_sched,
								   struct integer_list *interleaved_photo_GA_index_list,
								   struct integer_list *complete_GA_index_list, 
								   int marker, int num_big, int num_med, int num_small,
								   struct graphic_assembly_list *GA_list );
static void generateRandomPageSchedule ( struct page_schedule *pg_sched,
										 struct integer_list *photo_GA_index_list,
										 struct integer_list *complete_GA_index_list, 
										 struct graphic_assembly_list *GA_list );
static void makeAreaAspectHistogramFromLayout ( struct layout *L,
												struct twoD_double_array *area_aspect_hist );
static void makeAreaAspectHistogramFromPageSchedule ( struct page_schedule *pg_sched,
													  struct graphic_assembly_list *GA_list, 
													  struct twoD_double_array *area_aspect_hist );
static int areaAspectHistogramsAreEqual ( struct twoD_double_array *hist1,
										  struct twoD_double_array *hist2 );
static int areaAspectHistogramsDiffer ( struct twoD_double_array *hist1,
										struct twoD_double_array *hist2 );
static int pageScheduleIsNew ( int num_pages,
							   struct twoD_double_array *area_aspect_hists );
static void printPageSchedule ( struct page_schedule *pg_sched,
							    struct graphic_assembly_list *GA_list );
static void printCollectionSchedule ( struct collection_schedule *cs,
									  struct graphic_assembly_list *GA_list );
static void makeAltPageSchedules ( struct page_schedule *input_pg_sched,
								   struct collection_schedule *cs, 
								   struct graphic_assembly_list *GA_list,
								   int num_alts );
static int numPagesInPageListSequence ( struct page_list_sequence *pls );
static int pageIsNotNew ( int num_pages, struct twoD_double_array *area_aspect_hists );
static int pageIsNew ( int num_pages, struct twoD_double_array *area_aspect_hists );
static double lowestFixedDimActualToTargetAreaRatio ( struct pbook_page *page, 
													  struct graphic_assembly_list *GA_list );
static int decideToKeepPage ( struct config_params *cp, int num_pages, 
							  struct twoD_double_array *area_aspect_hists, 
							  struct pbook_page *page, struct graphic_assembly_list *GA_list );
static void selectAltPages ( struct config_params *cp, struct page_list_sequence *pls,
							 struct page_list *output_pg_list, int num_alts,
							 struct graphic_assembly_list *GA_list );
static void sortDoubles ( int N, double *x );
static int indexOfGEIDInGEIDList ( struct GE_identifier *GEID, struct GE_identifier_list *GEID_list );
static double averageRelativeArea ( struct page_schedule *pg_sched,
									struct GE_identifier_list *GEID_list );
static void rectifyPageSchedule ( struct page_schedule *pg_sched, 
								  struct graphic_assembly_list *GA_list );
static void reflectLayoutTopToBottom ( struct config_params *cp, struct layout *L );
static void reflectLayoutLeftToRight ( struct config_params *cp, struct layout *L );
static void makePhotoReassignmentLists ( struct pbook_page *page, 
										 struct double_list *VP_area_list,
										 struct integer_list *GA_VP_assignment_list,
										 struct graphic_assembly_list *GA_list );
static int indexOfNumberInIntegerList ( int number, struct integer_list *list );
static void makeFirstPossibleSwapList ( struct integer_list *swap_GA_list,
										struct integer_list *GA_VP_assignment_list,
										struct double_list *VP_area_list,
										int VP_area_list_position,
										struct graphic_assembly_list *GA_list );
static void makeSecondPossibleSwapList ( struct pbook_page *page, double curr_rel_area,
										 struct integer_list *first_swap_GA_list,
										 struct integer_list *second_swap_GA_list, 
										 struct graphic_assembly_list *GA_list );
static void makeThirdPossibleSwapList ( struct pbook_page *page,
										struct integer_list *second_swap_GA_list,
										struct integer_list *third_swap_GA_list, 
										struct graphic_assembly_list *GA_list );
static void printIntegerList ( struct integer_list *list );
static void reassignPhotosToViewports ( struct config_params *cp,
										struct pbook_page *page,
										struct graphic_assembly_list *GA_list );
static int millisecondValueFromLocalTime ( );
static void reportFixedDimensionsResult ( struct pbook_page *page, 
										  struct graphic_assembly_list *GA_list );
static double photoConsistency ( struct pbook_page *page, 
								 struct graphic_assembly_list *GA_list );
static double areaOfPhotos ( struct pbook_page *page, 
							 struct graphic_assembly_list *GA_list );
static double areaOfSmallestPhoto ( struct pbook_page *page, 
								    struct graphic_assembly_list *GA_list );
static int indexOfWorstPage ( struct page_list *pg_list,
							  struct graphic_assembly_list *GA_list );
static void removeWorstPages ( struct config_params *cp, struct page_list *pg_list,
							   struct graphic_assembly_list *GA_list );
static int decideToDoLayoutRotation ( struct config_params *cp, 
									  struct page_schedule *pg_sched, 
									  struct graphic_assembly_list *GA_list );
static void finishLayouts ( struct config_params *cp, struct page_list *pg_list,
						    struct graphic_assembly_list *GA_list );
static void initPageScheduleEntry ( struct page_schedule_entry *pse );
static void copyPageScheduleEntry ( struct page_schedule_entry *from_pse,
								    struct page_schedule_entry *to_pse );
static void copyPageSchedule ( struct page_schedule *from_sched,
							   struct page_schedule *to_sched );
static void makeOnepagePageSequence ( struct config_params *cp, 
									  struct page_sequence *pg_seq,
									  struct page_list_sequence *pls, 
									  int pbook_index, int pbook_page_index );
static void makePageSequence ( struct config_params *cp, struct page_sequence *pg_seq,
							   struct page_list_sequence *pls, int page_seq_index );
static void clearPageSequence ( struct page_sequence *pg_seq );
static void makePBookFilename ( struct config_params *cp, char *pbook_filename, 
							    char *base_filename, int page_seq_index );
static void makeOnepageFilename ( int num_pages, char *pbook_page_filename, 
								  char *pbook_filename, int page_number );
static void readGraphicAssemblySubtreesState ( FILE *fp, struct graphic_assembly *GA );
static void readPageSequenceState ( struct config_params *cp, struct page_sequence *pg_seq, 
									char *filename, struct graphic_assembly_list *GA_list );
static void writePageSequenceState ( struct config_params *cp, struct page_sequence *pg_seq, 
									 char *filename, struct graphic_assembly_list *GA_list );
static void readSubTTreeNodeState ( FILE *fp, struct subT_treeNode *node );
static void writeSubTTreeNodeState ( FILE *fp, struct subT_treeNode *node );
static void readGETreeNodeState ( FILE *fp, struct GE_treeNode *node );
static void writeGETreeNodeState ( FILE *fp, struct GE_treeNode *node );
static void readFixedDimensionsState ( FILE *fp, struct fixed_dimensions *fd );
static void readPhotoState ( FILE *fp, struct photo *ph );
static void writeFixedDimensionsState ( FILE *fp, struct fixed_dimensions *fd );
static void writeGraphicAssemblySubtreesState ( FILE *fp, struct graphic_assembly *GA );
static void writePhotoState ( FILE *fp, struct photo *ph );
static void readConfigParamsState ( FILE *fp, struct config_params *cp );
static int doublesDoNotDiffer ( double d1, double d2 );
static int doublesDiffer ( double d1, double d2 );
static void writeConfigParamsState ( FILE *fp, struct config_params *cp );
static void readPageScheduleState ( FILE *fp, struct page_schedule *pg_sched );
static void writePageScheduleState ( FILE *fp, struct page_schedule *pg_sched );
static void readLayoutState ( FILE *fp, struct layout *L,
							  struct graphic_assembly_list *GA_list );
static void writeLayoutState ( FILE *fp, struct layout *L, 
							   struct graphic_assembly_list *GA_list );
static void writePageSequenceText ( struct config_params *cp, 
									struct page_sequence *pg_seq, 
									int page_seq_index, char *pbook_filename,
									struct graphic_assembly_list *GA_list );
static void openStateFile ( const char *filename, FILE **fp, char *open_mode );
static void openTextFile ( const char *filename, FILE **fp );
static int totalNumGEs ( struct graphic_assembly_list *GA_list );
static void finishPageLayout ( struct config_params *cp, struct pbook_page *page,
							   struct graphic_assembly_list *GA_list );
static void computeVisibleRectangles ( struct config_params *cp, struct layout *L, 
									   struct graphic_assembly_list *GA_list );
static void computeVisibleRectangle ( struct config_params *cp, struct pixel_rectangle *v_rect, 
									  double output_aspect, struct photo *ph );
static int aspectsAreAboutEqual ( double x, double y, double tol );
static void verifyPixelRectanglesAreNested ( struct config_params *cp, 
											 struct pixel_rectangle *inner_rect,
											 struct pixel_rectangle *outer_rect );
static void printPixelRectangle ( struct pixel_rectangle *rect );
static void verifyPixelRectangleIsValid ( struct config_params *cp, 
										  struct pixel_rectangle *rect );
static void createAugmentedLayout ( struct layout *aug_L, struct layout *page_L, 
									struct GE_treeNode *GE_tree,
									int interior_node_GA_value );
static void computeObjPositions ( struct config_params *cp, 
								  struct GE_treeNode *GE_tree, 
								  struct layout *page_L, 
								  struct layout *aug_L, 
								  struct graphic_assembly_list *GA_list );
static void allocRegions ( struct config_params *cp,
						   struct pbook_page *page, struct GE_treeNode *GE_tree, 
						   struct graphic_assembly_list *GA_list, 
						   struct layout *aug_L, int value );
static int nodeIsRootOfSubtree ( struct GE_treeNode *node, struct GE_treeNode *GE_tree,
								 int num_leaves );
static void allocPage ( struct config_params *cp, struct pbook_page *page, 
					    struct graphic_assembly_list *GA_list, 
					    struct GE_treeNode *root, 
						struct physical_rectangle *p_rect );
static void addGARealizationToLayout ( struct layout *L, struct graphic_assembly *GA,
									   struct subT_identifier *subT_ID );
static int removeGAFromPage ( struct config_params *cp, struct pbook_page *page, 
							    int GA_index, struct graphic_assembly_list *GA_list );
static int numSubTIndexVectors ( struct page_schedule *pg_sched, struct graphic_assembly_list *GA_list );
static void generateSubTIndexVectors ( struct page_schedule *pg_sched, 
									   struct twoD_integer_array *subT_index_vecs,
									   struct graphic_assembly_list *GA_list );
static void plugInSubTIndexVector ( struct pbook_page *page, struct integer_list *subT_index_vec,
									struct graphic_assembly_list *GA_list );
static void setSubTIndices ( struct config_params *cp, struct pbook_page *page,
							 struct graphic_assembly_list *GA_list );
static void setPhotoRelativeAreasFromLayout ( struct pbook_page *page,
											  struct graphic_assembly_list *GA_list );
static void checkStrictSetDimensionsConditions ( struct pbook_page *page, 
												 struct graphic_assembly *GA,
												 struct graphic_assembly_list *GA_list );
static void clearROIs ( struct config_params *cp, struct pbook_page *page, 
						struct graphic_assembly_list *GA_list );
static void plugInROIs ( struct config_params *cp, struct pbook_page *page, 
						 struct GE_identifier *GEIDs, struct pixel_rectangle *ROIs, 
						 struct graphic_assembly_list *GA_list );
static void recordGEIDsFromLayout ( struct pbook_page *page, struct GE_identifier *GEIDs,
									struct graphic_assembly *selected_GA, 
									struct graphic_assembly_list *GA_list );
static int determineProposedROIsToSetDimensions ( struct config_params *cp, struct pbook_page *page,
												  struct graphic_assembly *selected_GA, 
												  struct GE_identifier *GEIDs,
												  struct pixel_rectangle *proposed_ROIs,
												  double height, double width, 
												  struct graphic_assembly_list *GA_list );
static void getPathsThroughGA ( struct config_params *cp, 
								struct pbook_page *page, int selected_GA_index,
								struct GE_treeNode *GE_tree, int node_value, 
								struct path *h_p, struct path *v_p, 
								struct graphic_assembly_list *GA_list );
static int GAIsInPath ( struct path *p, int GA_index, 
						struct GE_treeNode *GE_tree, int num_GEs );
static void startPathsThroughExistingLayout ( struct path *h_p, struct path *v_p, 
											  struct GE_treeNode *node,
											  struct pbook_page *page,
											  struct graphic_assembly_list *GA_list );
static int GAIsOnlyGAInPath ( int selected_GA, struct GE_treeNode *GE_tree, 
								 int num_GEs, int path_dir,
								 struct graphic_assembly_list *GA_list );
static int determineTargetDimensions ( struct config_params *cp, struct layout *L, 
									   struct GE_treeNode *GE_tree, 
									   struct GE_identifier *GEIDs,
									   double *target_heights, double *target_widths,
									   struct graphic_assembly *selected_GA,
									   double target_pbb_height, double target_pbb_width,
									   struct graphic_assembly_list *GA_list );
static void printGEIDs ( struct GE_identifier *GEIDs, 
						 struct graphic_assembly_list *GA_list,
						 struct layout *L, int num_GEs );
static void printMatrixAndVector ( double **a, double *b, int dimension );
static void populateDistanceTableau ( struct config_params *cp, struct layout *L, 
									  struct GE_treeNode *GE_tree, 
									  struct graphic_assembly_list *GA_list,
									  int node_value, int path_dir, struct path *p, 
									  double **a, double *b, int *row_count, 
									  struct graphic_assembly *selected_GA, 
									  double selected_GA_dimension, double pbb_dimension,
									  int *fixed_step_temp_flag, int *fixed_step_perm_flag,
									  struct GE_identifier *GEIDs );
static void finishDistanceTableau ( struct GE_treeNode *GE_tree, int num_GEs, 
									struct GE_identifier *GEIDs, struct path *p,
									struct graphic_assembly *selected_GA, 
									double *a_row, double *b_row, 
									double pbb_dimension );
static void putPathIntoDistanceTableauRow ( struct GE_treeNode *GE_tree, int num_GEs, 
											struct layout *L, struct GE_identifier *GEIDs,
											struct graphic_assembly_list *GA_list,
											struct path *L_p, struct path *R_p,
											struct graphic_assembly *selected_GA, 
											double *a_row, double *b_row, int cut_dir );
static void checkDirection ( int dir );
static void startPathForDistanceTableau ( int path_dir, struct path *p, struct GE_treeNode *node,
										  struct layout *L, struct graphic_assembly *selected_GA, 
										  double selected_GA_dimension, 
										  int *fixed_step_temp_flag, int *fixed_step_perm_flag,
										  struct graphic_assembly_list *GA_list );
static int indexOfGAInListOfGEIDs ( int GA_index, struct GE_identifier *GEIDs, 
									int num_GEs );
static int tryToSetDimensions ( struct config_params *cp, struct pbook_page *page, 
								struct graphic_assembly *GA, double height, double width,
								struct graphic_assembly_list *GA_list );
static void deduceMarginsFromLayout ( struct config_params *cp, struct layout *L );
static double maxExtentInLayout ( struct layout *L );
static void swapGAsInTree ( struct config_params *cp, struct pbook_page *page,
							struct subT_treeNode *GA_node_1, 
							struct subT_treeNode *GA_node_2 );
static int addGAToPage ( struct config_params *cp, struct pbook_page *page,
						   struct graphic_assembly *GA, 
						   int subT_index, int node_index, int cut_dir, 
						   struct graphic_assembly_list *GA_list );
static void removeGAFromLayout ( struct layout *L, struct graphic_assembly *GA );
static int placeGAOnPage ( struct config_params *cp, struct pbook_page *page, 
							 int GA_index, struct graphic_assembly_list *GA_list, 
							 int *subT_index, int *node_index, int *cut_dir );
static int GAIsOnPage ( struct pbook_page *page, int GA_index );
static void evaluatePotentialMove ( struct config_params *cp, struct potential_move *pmv, 
									struct pbook_page *page, int GA_index, 
									struct graphic_assembly_list *GA_list );
static void duplicatePage ( struct pbook_page *from_page, struct pbook_page *to_page );
static void duplicatePagesInPageList ( struct page_list *from_pg_list,
									   struct page_list *to_pg_list );
static void copyPage ( struct pbook_page *from_page, struct pbook_page *to_page );
static void copyLayout ( struct layout *from_L, struct layout *to_L );
static void determineMoveAllowability ( int *is_allowed, struct pbook_page *src_page );
static void optimizeLayout ( struct config_params *cp, 
							 struct pbook_page *page, 
							 struct graphic_assembly_list *GA_list );
static void executeChange ( struct config_params *cp, 
						    struct pbook_page *page, 
						    struct change_book *cb, struct change_spec *ch_spec, 
							struct graphic_assembly_list *GA_list );
static int executeTrade ( struct config_params *cp, 
						  struct pbook_page *page,
						  struct change_book *cb, struct change_spec *ch_spec, 
						  struct graphic_assembly_list *GA_list );
static int executeMove ( struct config_params *cp, 
						 struct pbook_page *page, 
						 struct change_book *cb, struct change_spec *ch_spec, 
						 struct graphic_assembly_list *GA_list );
static change_book_entry *cbEntryFromGAIndex ( struct change_book *cb, int GA_index );
static void updateChangeBook ( struct config_params *cp, 
							   struct pbook_page *page, 
							   struct change_book *cb, 
							   struct graphic_assembly_list *GA_list );
static void reportChange ( struct change_spec *ch_spec );
static void findBestChange ( struct change_book *cb, struct change_spec *ch_spec );
static int tradeIsBestChange ( struct potential_trade *ptd, struct change_spec *ch_spec );
static double scoreChange ( struct change_spec *ch_spec );
static int moveIsBestChange ( struct potential_move *pmv, struct change_spec *ch_spec );
static void initChangeBook ( struct config_params *cp, struct pbook_page *page, 
							 struct change_book *cb,
							 struct graphic_assembly_list *GA_list );
static void initChanges ( struct config_params *cp, struct pbook_page *page, 
						  struct change_book *cb, 
						  struct graphic_assembly_list *GA_list );
static void addGAsToChangeBook ( struct config_params *cp, 
								   struct pbook_page *page, 
								   struct change_book *cb );
static void evaluatePotentialTrade ( struct config_params *cp, 
									 struct potential_trade *ptd, 
									 struct pbook_page *page,
									 struct change_book *cb, int GA_index,
									 struct graphic_assembly_list *GA_list );
static void tryPlacingTwoGAsOnPage ( struct config_params *cp, 
									   struct pbook_page *src_page, 
									   struct pbook_page *scratch_page,
									   int this_GA_first, 
									   int *ptd_recorded, struct potential_trade *ptd, 
									   int GA_index, int exch_GA_index, 
									   struct graphic_assembly_list *GA_list );
static double uncroppedPhotoAspect ( struct photo *ph );
static void determineTradeAllowability ( int *is_allowed, struct pbook_page *src_page );
static void clearCollectionSchedule ( struct collection_schedule *cs );
static void genPhotoGrpSpec ( struct page_schedule *input_pg_sched,
							  struct graphic_assembly_spec *GA_spec, 
							  struct integer_list *GA_index_list, 
							  struct graphic_assembly_list *GA_list );
static void runPageSchedulePlacementTrials ( struct config_params *cp, 
											 struct page_list *pg_list, 
											 struct page_schedule *pg_sched,
											 struct graphic_assembly_list *GA_list );
static int numPhotosInLargestPhotoGroup ( struct page_schedule *pg_sched, 
										  struct graphic_assembly_list *GA_list );
static void printGAType ( struct graphic_assembly *GA );
static void runGAPlacementTrials ( struct config_params *cp, struct pbook_page *prev_page,
								   struct page_schedule_entry *pse, struct page_list *pg_list,
								   struct graphic_assembly_list *GA_list );
static void runOneGAPlacementTrial ( struct config_params *cp, struct pbook_page *prev_page,
								   struct graphic_assembly *GA, struct page_list *pg_list,
								   struct graphic_assembly_list *GA_list,
								   int subT_index, int node_index, int cut_dir );
static void submitPageToPageList ( struct config_params *cp, struct pbook_page *test_page,
								   struct page_list *pg_list );
static void addPageToPageList ( struct config_params *cp, struct pbook_page *test_page,
							    struct page_list *pg_list );
static void removePageFromPageList ( struct config_params *cp, struct pbook_page *page, 
									 struct page_list *pg_list );
static void checkPageList ( struct config_params *cp, struct page_list *pg_list,
						    struct page_schedule *pg_sched );
static double usableArea ( struct config_params *cp );
static double usableHeight ( struct config_params *cp );
static double usableWidth ( struct config_params *cp );
static void clearPagesInPageList ( struct config_params *cp, struct page_list *pg_list );
static void deletePageListSequence ( struct config_params *cp,
									struct page_list_sequence *pls );
static void clearPageTree ( struct pbook_page *page );
static void clearLayout ( struct layout *L );
static void clearPageScheduleEntry ( struct page_schedule_entry *pse );
static void clearPageSchedule ( struct page_schedule *pg_sched );
static void clearPage ( struct config_params *cp, struct pbook_page *page );
static void initPageList ( struct config_params *cp, struct page_list *pg_list );
static void initPage ( struct config_params *cp, struct pbook_page *page );
static int computeObjAreas ( struct config_params *cp, struct pbook_page *page, 
							 struct graphic_assembly_list *GA_list );
static void populateAreaTableau ( struct config_params *cp, 
								  struct pbook_page *page, struct GE_treeNode *GE_tree, 
								  struct graphic_assembly_list *GA_list,
								  int node_value, double **a, double *b,
								  struct path *h_p, struct path *v_p, int *count );
static int testDistancesSolution ( struct GE_treeNode *GE_tree,
								   double *computed_distances, struct path *p, 
								   struct GE_identifier *GEIDs, int num_GEs,
								   double target_path_length );
static int testAreasSolution ( struct config_params *cp, struct pbook_page *page, 
							   struct GE_treeNode *GE_tree, 
							   struct graphic_assembly_list *GA_list, double *solution, 
							   struct path *h_path, struct path *v_path );
static int computeObjAreasBRIC ( struct config_params *cp, struct pbook_page *page, 
								 struct GE_treeNode *GE_tree,
								 struct graphic_assembly_list *GA_list );
static double pathDistance ( struct config_params *cp, struct layout *L, 
							 struct GE_treeNode *GE_tree, struct path *p );
static void recordAreasFromSolnVec ( struct layout *L, double *solution,
									 struct GE_treeNode *GE_tree,
									 struct graphic_assembly_list *GA_list );
static int aValueIsNotPositive ( double *x, int N );
static void computeSolutionVector ( double **a, double *b, double *solution, int dimension );
static void finishAreaTableau ( struct pbook_page *page, struct GE_treeNode *GE_tree,
								struct graphic_assembly_list *GA_list,
								struct path *p, double **a, double *b );
static void putPathIntoAreaTableauRow ( struct GE_treeNode *GE_tree, int num_GEs, 
										struct graphic_assembly_list *GA_list,
										struct path *p, double *a_row, double *b_row, 
										double sign );
static void checkSign ( double sign );
static void copyMatrices ( double **a, double **temp_a,
						   double *b, double *temp_b, int N );
static void allocateMatrices ( double ***a, double **b, int N );
static void deleteMatrices ( double **a, double *b, int N );
static void clearMatrices ( double **a, double *b, int N );
static void MAP_deleteBrickEqnPaths ( struct path *paths, int num_GEs );
static void concatenatePaths ( struct config_params *cp, struct GE_treeNode *GE_tree, 
							   int num_GEs, 
							   struct path *to_path, struct path *L_from_path, 
							   struct path *R_from_path, struct GE_treeNode *node );
static void copyPath ( struct path *to_path, struct path *from_path );
static void startPathsForAreaTableau ( struct path *h_p, struct path *v_p, 
									   struct GE_treeNode *node,
									   struct page_schedule *pg_sched,
									   struct graphic_assembly_list *GA_list );
static double layoutScore ( struct config_params *cp, struct pbook_page *page, 
						    struct GE_treeNode *GE_tree,
							struct graphic_assembly_list *GA_list );
static double relativeAreaOfPageScheduleEntry ( struct page_schedule_entry *pse,
											    struct graphic_assembly_list *GA_list );
static double photoRelativeAreaFromPageSchedule ( struct page_schedule *pg_sched,
												  struct graphic_assembly_list *GA_list );
static double averageTargetAreaOfFixedDimensionsGA ( struct page_schedule_entry *pse,
													 struct graphic_assembly_list *GA_list );
static int numberOfFixedDimensionsGAs ( struct page_schedule *pg_sched,
										struct graphic_assembly_list *GA_list);
static double targetAreaOfFixedDimensionsGAs ( struct page_schedule *pg_sched,
											   struct graphic_assembly_list *GA_list);
static void computeTargetAreas ( struct config_params *cp, struct page_schedule *pg_sched,
								 struct graphic_assembly_list *GA_list );
static double conversionFactorEstimate ( struct config_params *cp, 
										 struct page_schedule *pg_sched,
										 struct graphic_assembly_list *GA_list );
static double reliableConversionFactorEstimate ( struct config_params *cp, 
												 struct page_schedule *pg_sched,
												 struct graphic_assembly_list *GA_list );
static void checkScoringTolerances ( double too_big, double way_too_big, 
									 double too_small, 
									 double way_too_small );
static double GEActualToTargetAreaRatio ( struct GE_identifier *GEID, struct pbook_page *page,
										  struct graphic_assembly_list *GA_list );
static double GEActualToTargetHeightRatio ( struct GE_identifier *GEID, struct pbook_page *page,
											struct graphic_assembly_list *GA_list );
static double GEActualToTargetWidthRatio ( struct GE_identifier *GEID, struct pbook_page *page,
										   struct graphic_assembly_list *GA_list );
static double fixedDimensionsVersionTargetAreaScore ( struct GE_identifier *GEID, 
													  struct pbook_page *page,
													  struct graphic_assembly_list *GA_list );
static double photoTargetAreaScore ( struct GE_identifier *GEID, struct pbook_page *page,
									  struct graphic_assembly_list *GA_list );
static double distanceMapping ( double ratio, double too_big, double way_too_big, 
								double too_small, double way_too_small );
static double photoGATargetAreaScore ( struct graphic_assembly *GA, 
										struct pbook_page *page,
										struct graphic_assembly_list *GA_list );
static double photoGrpGATargetAreaScore ( struct graphic_assembly *GA, 
										   struct pbook_page *page,
										   struct graphic_assembly_list *GA_list );
static double photoVerGATargetAreaScore ( struct graphic_assembly *GA, 
										   struct pbook_page *page,
										   struct graphic_assembly_list *GA_list );
static double fixedDimensionsGATargetAreaScore ( struct graphic_assembly *GA, 
												 struct pbook_page *page,
												 struct graphic_assembly_list *GA_list );
static double photoSeqGATargetAreaScore ( struct graphic_assembly *GA, 
										   struct pbook_page *page,
										   struct graphic_assembly_list *GA_list );
static double targetAreaScore ( struct pbook_page *page, 
								struct graphic_assembly_list *GA_list );
static double comboOfConsistencyAndAspect ( struct pbook_page *page, 
											struct GE_treeNode *GE_tree, 
											struct graphic_assembly_list *GA_list );
static double bbCoverage ( struct GE_treeNode *leaf, struct GE_treeNode *root );
static struct viewport *VPFromGEID ( struct GE_identifier *GE_ID, struct layout *L );
static double aspectMatch ( struct pbook_page *page, struct GE_treeNode *root );
static void FAAccumBBs ( struct config_params *cp, struct GE_treeNode *T, 
						  int num_GEs, int value );
static void extractPolishExpression ( struct subT_treeNode *T, int num_leaves,
									  int *P_e );
static void addToPolishExpression ( struct subT_treeNode *T, int num_leaves,
								    int value, int *P_e, int *count );
static void skewTree ( struct subT_treeNode *T, int num_leaves, int value );
static void linearizeTriad ( struct subT_treeNode *T, int num_leaves, 
							 struct subT_treeNode *node, 
							 struct subT_treeNode *Lchild, 
							 struct subT_treeNode *Rchild );
static void swapChildren ( struct subT_treeNode *parent, int L_value, int R_value );
static double bbWidth ( struct GE_treeNode *node );
static double bbHeight ( struct GE_treeNode *node );
static void checkContentInfo ( double R_a, double R_e, double L_a, double L_e );
static void FAInitTermNodeBBs ( struct config_params *cp,
								 struct GE_treeNode *GE_tree, struct layout *L,
								 struct graphic_assembly_list *GA_list );
static void subTToGE ( struct config_params *cp, struct GE_treeNode *new_GE_tree, 
						 struct pbook_page *page, int num_GEs,
						 struct graphic_assembly_list *GA_list );
static void GEReplaceLeafWithSubtree ( struct GE_treeNode *existing_tree,
										int existing_num_leaves, int value_displaced, 
										struct GE_treeNode *incoming_tree,
										int incoming_num_leaves );
static void genLeafMapping ( int *leaf_mapping, int value_displaced, 
							 int incoming_num_leaves, int existing_num_leaves );
static void adjustTreeValue ( int *value, int existing_num_leaves, int *leaf_mapping );
static double GEConsistency ( struct pbook_page *page,
								 struct graphic_assembly_list *GA_list );
static void updateMinAndMax ( double area, double *area_min, double *area_max );
static double GAAreaFromLayout ( struct graphic_assembly *GA, struct layout *L );
static double GAHeightFromLayout ( struct graphic_assembly *GA, struct layout *L );
static double GAWidthFromLayout ( struct graphic_assembly *GA, struct layout *L );
static double photoAspectFromLayout ( struct graphic_assembly *GA, struct layout *L );
static double photoAreaFromLayout ( struct graphic_assembly *GA, struct layout *L );
static double photoGrpPhotoAspectFromLayout ( struct graphic_assembly *GA, 
											  int photo_index, struct layout *L );
static double photoGrpPhotoAreaFromLayout ( struct graphic_assembly *GA, 
										    int photo_index, struct layout *L );
static double photoVerAreaFromLayout ( struct graphic_assembly *GA, struct layout *L );
static double fixedDimensionsVersionAreaFromLayout ( struct graphic_assembly *GA, 
													 struct layout *L );
static double photoSeqAreaFromLayout ( struct graphic_assembly *GA, struct layout *L );
static struct physical_rectangle *physRectFromGEID ( struct GE_identifier *GE_ID, 
													 struct layout *L );
static void verifyPhysRectDimensions ( struct physical_rectangle *p_rect );
static struct viewport *VPFromGAIndex ( int GA_index, struct layout *L );
static struct physical_rectangle *physRectFromGAIndex ( int GA_index, struct layout *L );
static int updateScore ( struct pbook_page *page, struct subT_treeNode *best_T,
						 struct layout *best_L,
						 struct graphic_assembly_list *GA_list );
static void clearScore ( );
static void printGAList ( struct graphic_assembly_list *GA_list );
static void printGraphicAssemblyInfo ( struct graphic_assembly *GA,
									   struct graphic_assembly_list *GA_list );
static void printTruncatedString ( char *string );
static char *filenameFromPath ( char *path );
static void genPhotoSublayouts ( int GA_index, struct graphic_assembly_list *GA_list );
static void getScratchPageAspects ( struct double_list *scratch_page_aspects );
static void recordPageTreeAsPhotoGrpSublayout ( struct config_params *cp,
												struct pbook_page *page,
												struct graphic_assembly *group_GA,
												int sublayout_index,
												struct graphic_assembly_list *GA_list );
static void genPhotoGrpSublayouts ( struct config_params *cp, int group_GA_index,
									struct graphic_assembly_spec *GA_spec,
									struct graphic_assembly_list *GA_list );
static void genPhotoVerSublayouts ( int GA_index, struct graphic_assembly_list *GA_list );
static void genFixedDimensionsSublayouts ( int GA_index, struct graphic_assembly_list *GA_list );
static void genPhotoSeqSublayouts ( int GA_index, struct graphic_assembly_list *GA_list );
static void genSublayouts ( struct config_params *cp, int GA_index,
							struct graphic_assembly_spec *GA_spec,
							struct graphic_assembly_list *GA_list );
static void generateGA ( struct config_params *cp, int GA_index,
						 struct graphic_assembly_spec *GA_spec,
						 struct graphic_assembly_list *GA_list );
static void fillInPhotoHeightField ( struct photo *ph, struct photo_spec *ph_spec );
static void fillInPhotoWidthField ( struct photo *ph, struct photo_spec *ph_spec );
static void fillInCropRegionField ( struct photo *ph, struct photo_spec *ph_spec );
static void fillInROIField ( struct photo *ph, struct photo_spec *ph_spec );
static void generatePhotoGA ( struct config_params *cp, int GA_index,
							  struct graphic_assembly_list *GA_list,
							  struct graphic_assembly_spec *GA_spec );
static void generatePhotoGrpGA ( struct config_params *cp, int GA_index,
								 struct graphic_assembly_list *GA_list,
								 struct graphic_assembly_spec *GA_spec );
static void generatePhotoVerGA ( struct config_params *cp, int GA_index,
								 struct graphic_assembly_list *GA_list,
								 struct graphic_assembly_spec *GA_spec );
static void generateFixedDimGA ( struct config_params *cp, int GA_index,
								 struct graphic_assembly_list *GA_list,
								 struct graphic_assembly_spec *GA_spec );
static void generatePhotoSeqGA ( struct config_params *cp, int GA_index,
								 struct graphic_assembly_list *GA_list,
								 struct graphic_assembly_spec *GA_spec );
static int allocateOneNewGA ( struct graphic_assembly_list *GA_list );
static void verifyPhotoDimensions ( struct photo_seq *ph_seq );
static void setSpacingValuesFromPageDimensions ( struct config_params *cp );
static void confirmSpacingValues ( struct config_params *cp ); 
static void checkConfigValues ( struct config_params *cp );
static void checkCarefulMode ( struct config_params *cp );
static void checkUseROI ( struct config_params *cp );
static void checkSpacingValues ( struct config_params *cp );
static void checkMargins ( struct config_params *cp );
static void checkLayoutRotationValues ( struct config_params *cp );
static void checkOptimizeLayoutValues ( struct config_params *cp );
static void checkFixedDimDiscardThreshold ( struct config_params *cp );
static void checkNumLayouts ( struct config_params *cp );
static int exeMode ( int argc, char **argv );

//added by Jun Xiao

char _IPHONE_PATH[_MAX_PATH];


void _splitpath ( const char* base_filename, char *drive, char* dir, char* fname, char* ext )
{
	strcpy(fname, base_filename);
}

void _makepath ( char* pbook_filename, const char* fname)
{
	//strcpy(pbook_filename, fname);
	strcpy(pbook_filename, _IPHONE_PATH);
	strcat(pbook_filename, fname);
}

static void openStateFile ( const char *filename, FILE **fp, char *open_mode )
{
	char error_message[255];
	char stt_name[_MAX_DIR];
	
	
	// if no extension given, add extension
	//	_splitpath( filename, drive, dir, fname, ext );

	_makepath(stt_name,filename);
	
	if ( ( *fp = fopen ( stt_name, open_mode ) ) == NULL ) {
		sprintf(error_message,"\n***cannot open output state file <%s>", stt_name);
		//		NSLog("fail");
		exitOrException(error_message);
	}
}

static void openTextFile (const char *filename, FILE **fp )
{
	char txt_name[_MAX_PATH];
	char error_message[255];
	
// if no extension given, add extension
	
	printf("\nfilename:%s\n", filename);
	_makepath(txt_name, filename);
	strcat(txt_name, ".txt");
	printf("\ntxtname:%s\n", txt_name);
	
	if ( ( *fp = fopen ( txt_name,"w" ) ) == NULL ) {
		sprintf(error_message,"\n***cannot open output file <%s>", txt_name);
		exitOrException(error_message);
	}
}


void _set_iphone_path(const char* filepath)
{
	strcpy(_IPHONE_PATH, filepath);
//	strcat(_IPHONE_PATH, "/");
}

void setConfigDefaults ( struct config_params *cp )
{
	cp->NUM_WORKING_LAYOUTS = 4;
	cp->NUM_OUTPUT_LAYOUTS = 1;
	cp->OPTIMIZE_LAYOUT_PPP_THRESHOLD = 0;
	
	cp->FIXED_DIM_DISCARD_THRESHOLD = 0.0;
	
	cp->LAYOUT_ROTATION = 1;
	cp->ROTATION_CAPACITY = 6;
	cp->ROTATION_PPP_THRESHOLD = 10;
	
	cp->INTER_GA_SPACING = -1.0;	// use spacing defaults only if necessary, 
	cp->PHOTO_GRP_SPACING = -1.0;	// and in that case, 
	cp->PHOTO_SEQ_SPACING = -1.0;	// compute them from the page dimensions
	
	cp->BORDER = 0.0;
	cp->USE_ROI = 1;
	cp->TXT_OUTPUT = 1;
	cp->OUTPUT_DPI = 1.0;
	cp->CAREFUL_MODE = 1;
	
	cp->pageHeight = 320;
	cp->pageWidth = 480;
	cp->leftMargin = 10;
	cp->rightMargin = 10;
	cp->topMargin = 10;
	cp->bottomMargin = 10;
}

void _BRIC_newpage(char *input, const char* pageid)
{
	struct config_params cp;
	struct content_file_transcript cft;
	setConfigDefaults(&cp);
	char *dummyFileName;
	
	const char *ptr = input;
	
	char photoid[32];
	char photowidth[32];
	char photoheight[32];
	
	int n;
	
	int count = 0;
	while ( sscanf(ptr, "%31[^;];%31[^;];%31[^;]%n", photoid, photowidth, photoheight, &n) == 3 )
	{
		printf("field = \"%s\"\n", photoid);
		printf("field = \"%s\"\n", photowidth);
		printf("field = \"%s\"\n", photoheight);
		ptr += n; 
		count ++;
		
		if ( *ptr != ';' )
		{
			break; 
		}
		++ptr; 
	}
	
	ptr = input;
		
	cft.num_items = count;
	//	cft.items = new int[cft.num_items];
	cft.GA_specs = new struct graphic_assembly_spec [cft.num_items];
	

	struct graphic_assembly_spec *GA_spec;
	struct photo_spec *ph_spec;
	count = 0;
	
	while ( sscanf(ptr, "%31[^;];%31[^;];%31[^;]%n", photoid, photowidth, photoheight, &n) == 3 )
	{
		ptr += n; 
		GA_spec = &( cft.GA_specs[count] );
		GA_spec->GA_index = -1;
		GA_spec->type = 1;
		
		ph_spec = &( GA_spec->ph_spec );
		
		// don't fill in the GE_ID value
		
		dummyFileName = new char[strlen(photoid)];
		strcpy(dummyFileName, photoid);
		ph_spec->filename =  dummyFileName;// put filename here
		ph_spec->pixel_height = atoi(photoheight);
		ph_spec->pixel_width = atoi(photowidth);
		ph_spec->has_crop_region = 0;
		ph_spec->has_ROI = 0;
		ph_spec->area = 1.0;
		
		if ( *ptr != ';' )
		{
			break; 
		}
		++ptr; 
		count++;
	}

	char layoutFilename[255];
	strcpy(layoutFilename, pageid);
	
	runNewPage(&cp, &cft, layoutFilename);

	
}

void _BRIC_alternative(const char* pageid)
{
	char fname[_MAX_FNAME];
	strcpy(fname, pageid);
	runDifferentPage(fname);
}

void _BRIC_swap(const char* pageid, int index1, int index2)
{
	char fname[_MAX_FNAME];
	strcpy(fname, pageid);
	runSwap(fname, index1, index2);
}

void _BRIC_replace(const char* pageid, int index, char *newPhoto)
{
	struct content_file_transcript cft;
	char *dummyFileName;	
	const char *ptr = newPhoto;
	
	char photoid[32];
	char photowidth[32];
	char photoheight[32];
	
	cft.num_items = 1;
	cft.GA_specs = new struct graphic_assembly_spec [cft.num_items];
	struct graphic_assembly_spec *GA_spec;
	struct photo_spec *ph_spec;
	
	int n;

	if ( sscanf(ptr, "%31[^;];%31[^;];%31[^;]%n", photoid, photowidth, photoheight, &n) == 3 )
	{
		GA_spec = &( cft.GA_specs[0] );
		GA_spec->GA_index = -1;
		GA_spec->type = 1;
		ph_spec = &( GA_spec->ph_spec );
		
		// don't fill in the GE_ID value		
		dummyFileName = new char[strlen(photoid)];
		strcpy(dummyFileName, photoid);
		ph_spec->filename =  dummyFileName;// put filename here
		ph_spec->pixel_height = atoi(photowidth);
		ph_spec->pixel_width = atoi(photoheight);
		ph_spec->has_crop_region = 0;
		ph_spec->has_ROI = 0;
		ph_spec->area = 1.0;
	}
	
	char fname[_MAX_FNAME];
	strcpy(fname, pageid);
	runReplace(fname, &cft, index);
}

// added by Jun Xiao


void writeOutput ( struct config_params *cp, struct page_list_sequence *pls, 
				  struct graphic_assembly_list *GA_list, 
				  char *base_filename )
{
	int i;
	struct page_sequence pg_seq;
	
	for ( i = 0; i < cp->NUM_OUTPUT_LAYOUTS; i++ ) {
//		makePBookFilename ( cp, filename, base_filename, i );
		
		if ( cp->TXT_OUTPUT ) {
						printf("writing text output for pbook %d ...\n",i);
			makePageSequence ( cp, &pg_seq, pls, i );
			writePageSequenceText ( cp, &pg_seq, i, base_filename, GA_list );
						printf("writing state of pbook %d ...\n",i);
			writePageSequenceState ( cp, &pg_seq, base_filename, GA_list );
			clearPageSequence ( &pg_seq );
		}
		else {
			exitOrException("\nexpected to write some form of output");
		}
	}
}


static void writePageSequenceText ( struct config_params *cp, 
								   struct page_sequence *pg_seq, 
								   int page_seq_index, char *pbook_filename,
								   struct graphic_assembly_list *GA_list )
{
	FILE *fp;
	struct pbook_page *page;
	struct layout *L;
	struct viewport *VP;
	struct physical_rectangle *p_rect;
//	struct pixel_rectangle *v_rect;
	struct photo *ph;
	int i, k;
	double upper_left_x, upper_left_y, lower_right_x, lower_right_y;
	
	openTextFile ( pbook_filename, &fp );
	
	for ( i = 0; i < pg_seq->num_pages; i++ ) {
		page = pg_seq->pages[i];
		
		if ( i > 0 ) { fprintf(fp,"NEWPAGE\n"); }
		
		L = &( page->page_L );
		
		for ( k = 0; k < L->num_VPs; k++ ) {
			VP = &( L->VPs[k] );
			
			// for photos, write the filename
			if ( typeOfGE ( &( VP->GE_ID ), GA_list ) == PHOTO ) {
				ph = photoFromGEID ( &( VP->GE_ID ), GA_list );
				fprintf(fp,"%s;",ph->filename);
			}
			else if ( typeOfGE ( &( VP->GE_ID ), GA_list ) == FIXED_DIM ) {
				fprintf(fp,"fixed-dimensions GA;");
			}
			else {
				exitOrException("\nnot prepared for GE that is neither PHOTO nor FIXED_DIM");
			}
			
			// write the GA index associated with this viewport
			fprintf(fp,"%d;",VP->GE_ID.GA_index);
			
			// write out the coordinates of the region on the physical page
			// for this viewport
			//
			// the x-axis starts at upper left corner of page and 
			// the positive direction is to the right; the y-axis starts
			// at the same point and the positive direction is down
			p_rect = &( VP->p_rect );
			upper_left_x = p_rect->horiz_offset * cp->OUTPUT_DPI;
			upper_left_y = ( cp->pageHeight - p_rect->vert_offset - p_rect->height ) * cp->OUTPUT_DPI;
			lower_right_x = ( p_rect->horiz_offset + p_rect->width ) * cp->OUTPUT_DPI;
			lower_right_y = ( cp->pageHeight - p_rect->vert_offset ) * cp->OUTPUT_DPI;
			fprintf(fp,"%d;", int(upper_left_x+0.5));
			fprintf(fp,"%d;",int(upper_left_y+0.5));
			fprintf(fp,"%d;",int(lower_right_x+0.5));
			fprintf(fp,"%d;",int(lower_right_y+0.5));
			
			// for photos, specify the rectangle of pixels to be mapped into the viewport
			if ( typeOfGE ( &( VP->GE_ID ), GA_list ) == PHOTO ) {
//				v_rect = &( VP->v_rect );
//				fprintf(fp,"%d;",v_rect->height);
//				fprintf(fp,"%d;",v_rect->width);
//				fprintf(fp,"%d;",v_rect->vert_offset);
//				fprintf(fp,"%d;",v_rect->horiz_offset);
			}
			else if ( typeOfGE ( &( VP->GE_ID ), GA_list ) == FIXED_DIM ) {
				// no rectangle of pixels in this case; 
				// just write something out so the same reader code will work
				fprintf(fp,"0;0;0;0;");
			}
			else {
				exitOrException("\nnot prepared for GE that is neither PHOTO nor FIXED_DIM");
			}
			
			//fprintf(fp,"\n");
		}
	}
	
	fclose(fp);
}

// notes regarding runNewPage:
//		- before using this function, first run setConfigDefaults, 
//		  then modify config_params to suit your application
//		- regarding the cft: 
//			- the cft must have at least one GA_spec
//			- for each GA_spec, set value of GA_index to 0
//		- 'outfile' is the base string for filenames to be written out
void runNewPage ( struct config_params *cp, struct content_file_transcript *cft, 
				 char *outfile )
{
	int i;
	struct graphic_assembly_list GA_list;
	struct page_list_sequence pls;
	struct page_schedule pg_sched;
	struct page_list *pg_list;
	struct pbook_page *page;
	
	seedPseudoRandomNumber ( 1 );
	confirmSpacingValues ( cp );
	checkConfigValues ( cp );
	
	// use the content file transcript to populate the GA_list,
	// then make a page schedule
	generateGAListFromCFT ( cp, &GA_list, cft );
	initPageSchedule ( &pg_sched, 0 );
	for ( i = 0 ; i < GA_list.num_GAs; i++ ) {
		addGAToPageSchedule ( &( GA_list.GA[i] ), &pg_sched );
	}
	recordAreasFromCollectionSchedule ( &pg_sched, cft, &GA_list );
	
	// allocate a structure to store the page lists 
	pls.page_lists = new struct page_list * [ 1 ];
	pls.num_page_lists = 0;
	
	// call the layout engine 
	pls.page_lists[0] = createPage ( cp, &GA_list, &pg_sched, -1 );
	(pls.num_page_lists)++;
	
	// report the fixed-dimensions result for the 1st page in the page list
	pg_list = pls.page_lists[0];
	page = &( pg_list->pages[0] );
	reportFixedDimensionsResult ( page, &GA_list );
	
	writeOutput ( cp, &pls, &GA_list, outfile );
	
	//	printf("-- DONE --\n");
}

void runDifferentPage ( char *state_file )
{
	int i;
	struct config_params cp;
	struct graphic_assembly_list GA_list;
	struct page_sequence input_pg_seq, output_pg_seq;
	struct page_list *pg_list;
	struct pbook_page *page;
	
	if ( strlen ( state_file ) == 0 ) {
		exitOrException("\nno state file specified");
	}
	printf("state file:  %s\n",state_file);
	
	// read the state file
	readPageSequenceState ( &cp, &input_pg_seq, state_file, &GA_list );
	if ( input_pg_seq.num_pages > 1 ) {
		exitOrException("\ndid not expect multiple pages in the input page sequence");
	}
	
	// first clear ROIs associated with photos, if there are any; 
	// then invoke the layout engine
	page = input_pg_seq.pages[0];
	clearROIs ( &cp, page, &GA_list );
	pg_list = createPage ( &cp, &GA_list, &( page->sched ), page->rotation_count );
	
	// convert page list into page sequence
	output_pg_seq.pages = new struct pbook_page * [ pg_list->num_pages ];
	output_pg_seq.num_pages = 0;
	for ( i = 0; i < pg_list->num_pages; i++ ) {
		output_pg_seq.pages[i] = &( pg_list->pages[i] );
		(output_pg_seq.num_pages)++;
	}
	
	// write the state file back out
	writePageSequenceText ( &cp, &output_pg_seq, 0, state_file, &GA_list );
	writePageSequenceState ( &cp, &output_pg_seq, state_file, &GA_list );
	reportFixedDimensionsResult ( output_pg_seq.pages[0], &GA_list );
	
	printf("-- DONE --\n");
}

void runReplace ( char *state_file, struct content_file_transcript *cft,
				 int leaving_GA_index )
{
	int incoming_GA_index;
	struct config_params cp;
	struct page_sequence pg_seq;
	struct pbook_page *page;
	struct graphic_assembly_list GA_list;
	
	if ( strlen ( state_file ) == 0 ) {
		exitOrException("\nno state file specified");
	}
	printf("state file:  %s\n",state_file);
	
	// read the state file
	readPageSequenceState ( &cp, &pg_seq, state_file, &GA_list );
	
	if ( cft->num_items != 1 ) {
		exitOrException("\nexpect content file to have exactly one GA");
	}
	incoming_GA_index = allocateOneNewGA ( &GA_list );
	generateGA ( &cp, incoming_GA_index, &( cft->GA_specs[0] ), &GA_list );
	
	// get the page
	if ( 0 >= pg_seq.num_pages ) {
		exitOrException("\npage number from command line is out of range exhibited in state file");
	}
	page = pg_seq.pages[0];
	
	printf("GA index of incoming photo: %d\n",incoming_GA_index);
	printf("state filename: %s\n",state_file);
	
	clearROIs ( &cp, page, &GA_list );
	if ( replaceGA ( &cp, page, leaving_GA_index, incoming_GA_index, &GA_list ) != PASS ) {
		exitOrException("\nerror replacing GA on page");
	}
	
	// write the state file back out
	writePageSequenceText ( &cp, &pg_seq, 0, state_file, &GA_list );
	writePageSequenceState ( &cp, &pg_seq, state_file, &GA_list );
	reportFixedDimensionsResult ( page, &GA_list );
	
	printf("-- DONE --\n");
}

void runSwap ( char *state_file, int GA_index_1, int GA_index_2 )
{
	struct config_params cp;
	struct graphic_assembly_list GA_list;
	struct page_sequence pg_seq;
	struct pbook_page *page;
	
	if ( strlen ( state_file ) == 0 ) {
		exitOrException("\nno state file specified");
	}
	printf("state file:  %s\n",state_file);
	
	// read the state file
	readPageSequenceState ( &cp, &pg_seq, state_file, &GA_list );
	if ( ( GA_index_1 < 0 ) || ( GA_index_1 >= GA_list.num_GAs ) ) {
		exitOrException("\ninvalid GA_index_1");
	}
	if ( ( GA_index_2 < 0 ) || ( GA_index_2 >= GA_list.num_GAs ) ) {
		exitOrException("\ninvalid GA_index_2");
	}
	
	// get the page
	if ( 0 >= pg_seq.num_pages ) {
		exitOrException("\npage number from command line is out of range exhibited in state file");
	}
	page = pg_seq.pages[0];
	
	clearROIs ( &cp, page, &GA_list );
	if ( swapGAs ( &cp, page, GA_index_1, GA_index_2, &GA_list ) != PASS ) {
		exitOrException("\nerror implementing swap");
	}
	
	// write the state file back out
	writePageSequenceText ( &cp, &pg_seq, 0, state_file, &GA_list );
	writePageSequenceState ( &cp, &pg_seq, state_file, &GA_list );
	reportFixedDimensionsResult ( page, &GA_list );
	
	printf("-- DONE --\n");
}



void pbookMain ( int argc, char **argv )
{
	int exe_mode;

	exe_mode = exeMode ( argc, argv );

	if ( exe_mode == NEWPAGE ) {
//		runNewPageExeMode ( argc, argv );
	}
	else if ( exe_mode == DIFFERENTPAGE ) {
//		runDifferentPageExeMode ( argc, argv );
	}
	else if ( exe_mode == SWAP ) {
//		runSwapExeMode ( argc, argv );
	}
	else if ( exe_mode == CROP ) {
//		runCropExeMode ( argc, argv );
	}
	else if ( exe_mode == SETBORDER ) {
//		runSetBorderExeMode ( argc, argv );
	}
	else if ( exe_mode == SETSPACING ) {
//		runSetSpacingExeMode ( argc, argv );
	}
	else if ( exe_mode == SETMARGIN ) {
//		runSetMarginExeMode ( argc, argv );
	}
	else if ( exe_mode == SETBSM ) {
//		runSetBSMExeMode ( argc, argv );
	}
	else if ( exe_mode == SETDIMENSIONS ) {
//		runSetDimensionsExeMode ( argc, argv );
	}
	else if ( exe_mode == REPLACE ) {
//		runReplaceExeMode ( argc, argv );
	}
	else {
		exitOrException("\ninvalid exe mode");
	}
}

// notes regarding the content file transcript (cft) in runReplace:
//		- the cft must have exactly one GA_spec
//		- for the GA_spec, set value of GA_index to 0

int replaceGA ( struct config_params *cp, struct pbook_page *page,
				int leaving_GA_index, int incoming_GA_index, 
				struct graphic_assembly_list *GA_list )
{
	double area;
	struct graphic_assembly *leaving_GA, *incoming_GA;
	struct subT_identifier subT_ID;
	struct subT_treeNode *node;

	if ( ( leaving_GA_index < 0 ) || ( leaving_GA_index >= GA_list->num_GAs ) ) {
		exitOrException("\ninvalid GA_index for leaving photo");
		return FAIL;
	}

	// plug photo areas into page schedule as the photos' relative areas;

	// record the area of the leaving GA in the input page layout;
	// remove the leaving GA from the page schedule; 
	// add the incoming GA to the page schedule;
	// if the incoming GA is a photo, plug in the area of leaving GA as its relative area;
	// compute target areas in case we need to select GA subtree indices during reflow
	setPhotoRelativeAreasFromLayout ( page, GA_list );
	leaving_GA = &( GA_list->GA[leaving_GA_index] );
	area = GAAreaFromLayout ( leaving_GA, &( page->page_L ) );
	removeGAFromPageSchedule ( leaving_GA_index, &( page->sched ) );
	incoming_GA = &( GA_list->GA[incoming_GA_index] );
	addGAToPageSchedule ( incoming_GA, &( page->sched ) );
	if ( typeOfGA ( incoming_GA ) == PHOTO ) {
		recordAreasFromThinAir ( &( page->sched ), incoming_GA_index, GA_list, area );
	}
	computeTargetAreas ( cp, &(page->sched), GA_list );

	// effect the replacement in the page tree structure 
	subT_ID.GA_index = incoming_GA->GA_index;
	subT_ID.subT_index = 0;
	node = subTTreeNodeFromGAIndex ( page, leaving_GA_index );
	node->subT_ID = subT_ID;

	// remove the leaving GA from the layout structure;
	// add an appropriate instance of the incoming GA in the layout structure
	removeGAFromLayout ( &( page->page_L ), &( GA_list->GA[leaving_GA_index] ) );
	addGARealizationToLayout ( &( page->page_L ), incoming_GA, &subT_ID );

	if ( reflowPage ( cp, page, true, GA_list ) != PASS ) {
		exitOrException("\nerror implementing replacement");
		return FAIL;
	}

	return PASS;
}

void runSetDimensions ( char *state_file, int GA_index, double height, double width )
{
	struct config_params cp;
	struct graphic_assembly_list GA_list;
	struct page_sequence pg_seq;
	struct pbook_page *page;

	if ( strlen ( state_file ) == 0 ) {
		exitOrException("\nno state file specified");
	}
	printf("state file:  %s\n",state_file);
	if ( ( height < EPSILON ) || ( width < EPSILON ) ) {
		exitOrException("\nexpect positive target dimensions for selected graphic assembly");
	}

	// read the state file
	readPageSequenceState ( &cp, &pg_seq, state_file, &GA_list );
	if ( ( GA_index < 0 ) || ( GA_index >= GA_list.num_GAs ) ) {
		exitOrException("\ninvalid GA_index");
	}

	// get the page
	if ( 0 >= pg_seq.num_pages ) {
		exitOrException("\npage number from command line is out of range exhibited in state file");
	}
	page = pg_seq.pages[0];

	if ( setDimensions ( &cp, page, GA_index, height, width, &GA_list ) != PASS ) {
		exitOrException("\nerror implementing setDimensions");
	}

	// write the state file back out
	writePageSequenceText ( &cp, &pg_seq, 0, state_file, &GA_list );
	writePageSequenceState ( &cp, &pg_seq, state_file, &GA_list );
	reportFixedDimensionsResult ( page, &GA_list );

	printf("-- DONE --\n");
}

void runSetBSM ( char *state_file, double border, double spacing, 
				 double leftMargin, double rightMargin, 
				 double topMargin, double bottomMargin )
{
	int i;
	struct config_params cp;
	struct graphic_assembly_list GA_list;
	struct page_sequence pg_seq;
	struct pbook_page *page;

	if ( strlen ( state_file ) == 0 ) {
		exitOrException("\nno state file specified");
	}
	printf("state file:  %s\n",state_file);

	if ( ( border < 0.0 - EPSILON ) || ( spacing < 0.0 - EPSILON ) || 
		 ( leftMargin < 0.0 - EPSILON ) || ( rightMargin < 0.0 - EPSILON ) || 
		 ( topMargin < 0.0 - EPSILON ) || ( bottomMargin < 0.0 - EPSILON ) ) {
		exitOrException("\ndid not expect negative number for border, spacing or margins");
	}

	// read the state file
	readPageSequenceState ( &cp, &pg_seq, state_file, &GA_list );

	// only need one reflow ... use the call to setMarginOnPage
	cp.BORDER = border;
	cp.INTER_GA_SPACING = spacing;
	resetSublayoutSpacingValues ( &cp, &GA_list );
	cp.leftMargin = leftMargin;
	cp.rightMargin = rightMargin;
	cp.topMargin = topMargin;
	cp.bottomMargin = bottomMargin;
	for ( i = 0; i < pg_seq.num_pages; i++ ) {
		page = pg_seq.pages[i];
		clearROIs ( &cp, page, &GA_list );
		if ( setMarginOnPage ( &cp, page, &GA_list ) != PASS ) {
			exitOrException("\nerror implementing setBSM");
		}
	}

	// write the state file back out
	writePageSequenceText ( &cp, &pg_seq, 0, state_file, &GA_list );
	writePageSequenceState ( &cp, &pg_seq, state_file, &GA_list );
	reportFixedDimensionsResult ( page, &GA_list );

	printf("-- DONE --\n");
}

void runSetMargin ( char *state_file, double leftMargin, double rightMargin, 
					double topMargin, double bottomMargin )
{
	int i;
	struct config_params cp;
	struct graphic_assembly_list GA_list;
	struct page_sequence pg_seq;
	struct pbook_page *page;

	if ( strlen ( state_file ) == 0 ) {
		exitOrException("\nno state file specified");
	}
	printf("state file:  %s\n",state_file);

	if ( ( leftMargin < 0.0 - EPSILON ) || ( rightMargin < 0.0 - EPSILON ) || 
		 ( topMargin < 0.0 - EPSILON ) || ( bottomMargin < 0.0 - EPSILON ) ) {
		exitOrException("\ndid not expect negative number for any margin");
	}

	// read the state file
	readPageSequenceState ( &cp, &pg_seq, state_file, &GA_list );

	// set the margin values in all relevant structures and reflow the pages 
	cp.leftMargin = leftMargin;
	cp.rightMargin = rightMargin;
	cp.topMargin = topMargin;
	cp.bottomMargin = bottomMargin;
	for ( i = 0; i < pg_seq.num_pages; i++ ) {
		page = pg_seq.pages[i];
		clearROIs ( &cp, page, &GA_list );
		if ( setMarginOnPage ( &cp, page, &GA_list ) != PASS ) {
			exitOrException("\nerror implementing setmargin");
		}
	}

	// write the state file back out
	writePageSequenceText ( &cp, &pg_seq, 0, state_file, &GA_list );
	writePageSequenceState ( &cp, &pg_seq, state_file, &GA_list );
	reportFixedDimensionsResult ( page, &GA_list );

	printf("-- DONE --\n");
}

int setMarginOnPage ( struct config_params *cp, struct pbook_page *page, 
					  struct graphic_assembly_list *GA_list )
{
	checkConfigValues ( cp );

	page->usable_height = usableHeight ( cp );
	page->usable_width = usableWidth ( cp );

	// plug photo areas into page schedule as the photos' relative areas;
	// compute target areas in case we need to select GA subtree indices during reflow
	setPhotoRelativeAreasFromLayout ( page, GA_list );
	computeTargetAreas ( cp, &(page->sched), GA_list );

	if ( reflowPage ( cp, page, true, GA_list ) != PASS ) {
		exitOrException("\nerror setting spacing on page");
		return FAIL;
	}

	return PASS;
}

void runSetSpacing ( char *state_file, double spacing )
{
	int i;
	struct config_params cp;
	struct graphic_assembly_list GA_list;
	struct page_sequence pg_seq;
	struct pbook_page *page;

	if ( strlen ( state_file ) == 0 ) {
		exitOrException("\nno state file specified");
	}
	printf("state file:  %s\n",state_file);

	if ( spacing < 0.0 - EPSILON ) {
		exitOrException("\ndid not expect negative number for spacing value");
	}

	// read the state file
	readPageSequenceState ( &cp, &pg_seq, state_file, &GA_list );

	// reflow the pages 
	for ( i = 0; i < pg_seq.num_pages; i++ ) {
		page = pg_seq.pages[i];
		clearROIs ( &cp, page, &GA_list );
		if ( setSpacingOnPage ( &cp, page, spacing, &GA_list ) != PASS ) {
			exitOrException("\nerror implementing setspacing");
		}
	}

	// write the state file back out
	writePageSequenceText ( &cp, &pg_seq, 0, state_file, &GA_list );
	writePageSequenceState ( &cp, &pg_seq, state_file, &GA_list );
	reportFixedDimensionsResult ( page, &GA_list );

	printf("-- DONE --\n");
}

int setSpacingOnPage ( struct config_params *cp, struct pbook_page *page, 
			 		   double spacing, struct graphic_assembly_list *GA_list )
{
	if ( spacing < 0.0 - EPSILON ) {
		exitOrException("\ndid not expect negative spacing value");
		return FAIL;
	}

	// set the spacing value in all relevant structures
	cp->INTER_GA_SPACING = spacing;
	resetSublayoutSpacingValues ( cp, GA_list );

	// plug photo areas into page schedule as the photos' relative areas;
	// compute target areas in case we need to select GA subtree indices during reflow
	setPhotoRelativeAreasFromLayout ( page, GA_list );
	computeTargetAreas ( cp, &(page->sched), GA_list );

	if ( reflowPage ( cp, page, true, GA_list ) != PASS ) {
		exitOrException("\nerror setting spacing on page");
		return FAIL;
	}

	return PASS;
}

void runSetBorder ( char *state_file, double border )
{
	int i;
	struct config_params cp;
	struct graphic_assembly_list GA_list;
	struct page_sequence pg_seq;
	struct pbook_page *page;

	if ( strlen ( state_file ) == 0 ) {
		exitOrException("\nno state file specified");
	}
	printf("state file:  %s\n",state_file);

	if ( border < 0.0 - EPSILON ) {
		exitOrException("\ndid not expect negative number for border value");
	}

	// read the state file
	readPageSequenceState ( &cp, &pg_seq, state_file, &GA_list );

	for ( i = 0; i < pg_seq.num_pages; i++ ) {
		page = pg_seq.pages[i];
		clearROIs ( &cp, page, &GA_list );
		if ( setBorderOnPage ( &cp, page, border, &GA_list ) != PASS ) {
			exitOrException("\nerror implementing setborder");
		}
	}

	// write the state file back out
	writePageSequenceText ( &cp, &pg_seq, 0, state_file, &GA_list );
	writePageSequenceState ( &cp, &pg_seq, state_file, &GA_list );
	reportFixedDimensionsResult ( page, &GA_list );

	printf("-- DONE --\n");
}

int setBorderOnPage ( struct config_params *cp, struct pbook_page *page, 
			 		  double border, struct graphic_assembly_list *GA_list )
{
	if ( border < 0.0 - EPSILON ) {
		exitOrException("\ndid not expect negative border value");
		return FAIL;
	}

	// set the border value in all relevant structures
	cp->BORDER = border;
	resetSublayoutSpacingValues ( cp, GA_list );

	// plug photo areas into page schedule as the photos' relative areas;
	// compute target areas in case we need to select GA subtree indices during reflow
	setPhotoRelativeAreasFromLayout ( page, GA_list );
	computeTargetAreas ( cp, &(page->sched), GA_list );

	if ( reflowPage ( cp, page, true, GA_list ) != PASS ) {
		exitOrException("\nerror setting border on page");
		return FAIL;
	}

	return PASS;
}

void runCrop ( char *state_file, int GA_index, 
			   int height, int width, int vert_offset, int horiz_offset )
{
	struct pixel_rectangle ROI;
	struct config_params cp;
	struct graphic_assembly_list GA_list;
	struct page_sequence pg_seq;
	struct pbook_page *page;

	if ( strlen ( state_file ) == 0 ) {
		exitOrException("\nno state file specified");
	}
	printf("state file:  %s\n",state_file);

	if ( ( height < 0 ) || ( width < 0 ) || ( vert_offset < 0 ) || ( horiz_offset < 0 ) ) {
		exitOrException("\ninvalud region-of-interest given in crop instructions");
	}
	ROI.height = height;
	ROI.width = width;
	ROI.vert_offset = vert_offset;
	ROI.horiz_offset = horiz_offset;

	// read the state file
	readPageSequenceState ( &cp, &pg_seq, state_file, &GA_list );
	if ( ( GA_index < 0 ) || ( GA_index >= GA_list.num_GAs ) ) {
		exitOrException("\ninvalid GA_index");
	}

	// get the page
	if ( 0 >= pg_seq.num_pages ) {
		exitOrException("\npage number from command line is out of range exhibited in state file");
	}
	page = pg_seq.pages[0];

	clearROIs ( &cp, page, &GA_list );
	if ( cropPhotoOnPage ( &cp, page, GA_index, ROI.height, ROI.width, 
						   ROI.vert_offset, ROI.horiz_offset, &GA_list ) != PASS ) {
		exitOrException("\nerror cropping photo on page");
	}

	// write the state file back out
	writePageSequenceText ( &cp, &pg_seq, 0, state_file, &GA_list );
	writePageSequenceState ( &cp, &pg_seq, state_file, &GA_list );
	reportFixedDimensionsResult ( page, &GA_list );

	printf("-- DONE --\n");
}

int cropPhotoOnPage ( struct config_params *cp, struct pbook_page *page, int GA_index, 
					  int height, int width, int vert_offset, int horiz_offset,
					  struct graphic_assembly_list *GA_list )
{
	struct graphic_assembly *GA;
	struct photo *ph;

	// get the GA and verify it is on the page
	if ( ( GA_index < 0 ) || ( GA_index >= GA_list->num_GAs ) ) {
		exitOrException("\ninvalid GA_index supplied on cmd-line");
		return FAIL;
	}
	GA = &( GA_list->GA[GA_index] );
	if ( GA_index != GA->GA_index ) {
		exitOrException("\ninvalid GA_index supplied on cmd-line or read from state file");
		return FAIL;
	}
	if ( !GAIsOnPage ( page, GA_index ) ) {
		exitOrException("GA with supplied GA_index is not on the page; unable to complete crop");
		return FAIL;
	}

	if ( typeOfGA ( GA ) != PHOTO ) {
		exitOrException("\nnot prepared to crop GA that is not of type PHOTO");
		return FAIL;
	}
	ph = &( GA->ph );

	// if the photo has an ROI, clear it
	ph->has_ROI = 0;

	// set the crop_region 
	if ( pixelRectIsProperSubsetOfPhoto ( cp, ph, height, width, vert_offset, horiz_offset ) ) {
		// set the ROI in the GA_list
		ph->crop_region.height = height;
		ph->crop_region.width = width;
		ph->crop_region.vert_offset = vert_offset;
		ph->crop_region.horiz_offset = horiz_offset;
		ph->has_crop_region = 1;
	}
	else {
		// clear the ROI
		ph->crop_region.height = 0;
		ph->crop_region.width = 0;
		ph->crop_region.vert_offset = 0;
		ph->crop_region.horiz_offset = 0;
		ph->has_crop_region = 0;
	}

	// plug photo areas into page schedule as the photos' relative areas;
	// compute target areas in case we need to select GA subtree indices during reflow
	setPhotoRelativeAreasFromLayout ( page, GA_list );
	computeTargetAreas ( cp, &(page->sched), GA_list );

	if ( reflowPage ( cp, page, true, GA_list ) != PASS ) {
		exitOrException("\nerror implementing crop");
		return FAIL;
	}

	return PASS;
}

static int ROIIsProperSubsetOfPhoto ( struct config_params *cp, struct photo *ph, 
									  struct pixel_rectangle *ROI )
{
	verifyROIAndPhotoInfoAreValid ( cp, ph, ROI );

	if ( ( ROI->horiz_offset > 0 ) || ( ROI->vert_offset > 0 ) ||
		 ( ROI->horiz_offset + ROI->width < ph->width - 1 ) ||
		 ( ROI->vert_offset + ROI->height < ph->height - 1 ) ) {
		return ( 1 );
	}

	return ( 0 );
}

static int pixelRectIsProperSubsetOfPhoto ( struct config_params *cp, struct photo *ph, 
											int height, int width, int vert_offset,
											int horiz_offset )
{
	struct pixel_rectangle ROI;

	ROI.height = height;
	ROI.width = width;
	ROI.vert_offset = vert_offset;
	ROI.horiz_offset = horiz_offset;

	verifyROIAndPhotoInfoAreValid ( cp, ph, &ROI );

	if ( ( ROI.horiz_offset > 0 ) || ( ROI.vert_offset > 0 ) ||
		 ( ROI.horiz_offset + ROI.width < ph->width - 1 ) ||
		 ( ROI.vert_offset + ROI.height < ph->height - 1 ) ) {
		return ( 1 );
	}

	return ( 0 );
}

static void verifyROIAndPhotoInfoAreValid ( struct config_params *cp, struct photo *ph, 
											struct pixel_rectangle *ROI )
{
	int highest_row, highest_col;

	// verify the ROI dimensions are postive,
	// and that the ROI offsets are non-negative
	if ( ( ROI->height <= 0 ) || ( ROI->width <= 0 ) ||
		 ( ROI->vert_offset < 0 ) || ( ROI->horiz_offset < 0 ) ) {
		exitOrException("\ninvalid region of interest");
	}

	// verify photo dimensions are positive
	if ( ( ph->height <= 0 ) || ( ph->width <= 0 ) ) {
		exitOrException("\ndid not expect negative photo dimensions when verifying ROI is valid");
	}

	highest_row = ROI->vert_offset + ROI->height - 1;
	highest_col = ROI->horiz_offset + ROI->width - 1;

	// this "if statement" added to reproduce a commenting-out of code 
	// by Mei Zhang around Feb 2008 
	// to allow reflow after replacement with a new image
	if ( cp->CAREFUL_MODE == 1 ) {


		if ( ( highest_row >= ph->height ) || ( highest_col >= ph->width ) ) {
			exitOrException("\nROI extends outside bounds of photo pixel dimensions");
		}


	}
}



void respondToExitOrException ( const char* filename, int line_number, 
								const char* description )
{
	char message[255];

	if ( description == NULL ) {
		description = "a significant error has occured;\n";
	}
	sprintf ( message, "%s\n[%s,%d]", description, filename, line_number );

#if ( COMMAND_LINE )
	printf ( message );
	printf ( "\n" );
	exit ( 1 );
#else
	::MessageBox ( NULL, message, "Layout Engine Error", MB_OK );
	throw ( LAYOUTENGINE_EXCEPTION );
#endif
}

static void generateGAListFromCFT ( struct config_params *cp, 
									struct graphic_assembly_list *GA_list,
									struct content_file_transcript *cft )
{
	int i, j, GA_index;
	struct graphic_assembly_spec *GA_spec, photo_GA_spec;
	struct photo_grp_spec *ph_grp_spec;
	struct photo_spec *ph_spec;

	if ( cft->num_items < 1 ) {
		exitOrException("\nexpect content file transcript to have at least one GA_spec");
	}

	GA_list->num_GAs = 0;
	for ( i = 0; i < cft->num_items; i++ ) {
		// add a GA to the GA_list
		GA_index = allocateOneNewGA ( GA_list );

		if ( GA_index != i ) {
			exitOrException ( "\nerror generating GA_list from content file transcript" );
		}
	}
	// there is one GA in the GA_list for each item in the CFT 

	// for each photo group specification, 
	// make a separate graphic assembly for each photo in the photo group;
	// 
	// this has to be done before we can make a GA for the photo group
	for ( i = 0; i < cft->num_items; i++ ) {
		GA_spec = &( cft->GA_specs[i] );

		if ( GA_spec->type == PHOTO_GRP ) {
			ph_grp_spec = &( GA_spec->ph_grp_spec );

			for ( j = 0; j < ph_grp_spec->num_photo_specs; j++ ) {
				ph_spec = &( ph_grp_spec->ph_specs[j] );

				photo_GA_spec.GA_index  = allocateOneNewGA ( GA_list );
				photo_GA_spec.type = PHOTO;
				photo_GA_spec.ph_spec = *ph_spec;

				generateGA ( cp, photo_GA_spec.GA_index, &photo_GA_spec, GA_list );
			}
		}
	}

	// now make a GA for each item in the CFT
	for ( i = 0; i < cft->num_items; i++ ) {
		GA_spec = &( cft->GA_specs[i] );
		// recall GA_spec_index equals the GA_index for the CFT item
		generateGA ( cp, i, GA_spec, GA_list );
	}

	printGAList ( GA_list );
}

static struct fixed_dimensions_version_spec *fixedDimensionsVersionSpecFromGEID ( struct GE_identifier *GE_ID,
																				  struct graphic_assembly_spec *GA_spec )
{
	int i, count;
	struct fixed_dimensions_spec *fd_spec;
	struct fixed_dimensions_version_spec *fd_ver_spec, *soughtafter_fd_ver_spec;

	if ( GA_spec->type != FIXED_DIM ) {
		exitOrException("\nerror getting fd_ver_spec from GA_spec using GE_ID");
	}

	fd_spec = &( GA_spec->fd_spec );
	count = 0;
	for ( i = 0; i < fd_spec->num_fd_version_specs; i++ ) {
		fd_ver_spec = &( fd_spec->fd_version_specs[i] );

		if ( GEIDsAreEqual ( &( fd_ver_spec->GE_ID ), GE_ID ) ) {
			count++;
			soughtafter_fd_ver_spec = fd_ver_spec;
		}
	}

	if ( count != 1 ) {
		exitOrException("\nerror getting fd_ver_spec from GA_spec using GE_ID");
	}

	return ( soughtafter_fd_ver_spec );
}

static struct photo_spec *photoSpecFromGEID ( struct GE_identifier *GE_ID,
											  struct graphic_assembly_spec *GA_spec )
{
	int i, num_ph_specs, count;
	struct photo_spec *ph_specs, *ph_spec, *soughtafter_ph_spec;
	struct photo_grp_spec *ph_grp_spec;
	struct photo_ver_spec *ph_ver_spec;
	struct photo_seq_spec *ph_seq_spec;

	if ( GA_spec->type == PHOTO ) {
		num_ph_specs = 1;
		ph_specs = &( GA_spec->ph_spec );
	}
	else if ( GA_spec->type == PHOTO_GRP ) {
		ph_grp_spec = &( GA_spec->ph_grp_spec );

		num_ph_specs = ph_grp_spec->num_photo_specs;
		ph_specs = ph_grp_spec->ph_specs;
	}
	else if ( GA_spec->type == PHOTO_VER ) {
		ph_ver_spec = &( GA_spec->ph_ver_spec );

		num_ph_specs = ph_ver_spec->num_photo_specs;
		ph_specs = ph_ver_spec->ph_specs;
	}
	else if ( GA_spec->type == PHOTO_SEQ ) {
		ph_seq_spec = &( GA_spec->ph_seq_spec );

		num_ph_specs = ph_seq_spec->num_photo_specs;
		ph_specs = ph_seq_spec->ph_specs;
	}
	else {
		exitOrException("\nerror getting ph_spec from GA_spec using GE_ID");
	}

	count = 0;
	for ( i = 0; i < num_ph_specs; i++ ) {
		ph_spec = &( ph_specs[i] );

		if ( GEIDsAreEqual ( &( ph_spec->GE_ID ), GE_ID ) ) {
			count++;
			soughtafter_ph_spec = ph_spec;
		}
	}

	if ( count != 1 ) {
		exitOrException("\nerror getting ph_spec from GA_spec using GE_ID");
	}

	return ( soughtafter_ph_spec );
}

static void recordAreasFromGASpec ( struct page_schedule_entry *pse,
									struct graphic_assembly_spec *GA_spec )
{
	int i;
	double area_value;
	struct graphic_element_schedule *GE_sched;
	struct photo_spec *ph_spec;
	struct fixed_dimensions_version_spec *fd_ver_spec;

	for ( i = 0; i < pse->num_GEs; i++ ) {
		GE_sched = &( pse->GE_scheds[i] );

		area_value = -1.0;
		if ( ( GA_spec->type == PHOTO ) || ( GA_spec->type == PHOTO_SEQ ) ) {
			ph_spec = photoSpecFromGEID ( &( GE_sched->GE_ID ), GA_spec );
			area_value = ph_spec->area;
		}
		else if ( GA_spec->type == FIXED_DIM ) {
			fd_ver_spec = fixedDimensionsVersionSpecFromGEID ( &( GE_sched->GE_ID ), GA_spec );
			area_value = fd_ver_spec->height * fd_ver_spec->width;
		}

		if ( area_value < EPSILON ) {
			exitOrException("\nerror recording areas from GA specification");
		}
		GE_sched->relative_area = area_value;
	}
}

static void assignAreaValuesToPhotoSpecs ( struct graphic_assembly_spec *GA_spec )
{
	int i;
	struct photo_spec *ph_spec;
	struct photo_grp_spec *ph_grp_spec;
	struct photo_ver_spec *ph_ver_spec;
	struct fixed_dimensions_spec *fd_spec;
	struct fixed_dimensions_version_spec *fd_ver_spec;
	struct photo_seq_spec *ph_seq_spec;

	if ( typeOfGASpec ( GA_spec ) == PHOTO ) {
		ph_spec = &( GA_spec->ph_spec );

		if ( ph_spec->area < EPSILON ) {
			ph_spec->area = 1.0;	// default value
		}
		else {
			// area value was assigned a value from the content file
		}
	}
	else if ( typeOfGASpec ( GA_spec ) == PHOTO_GRP ) {
		ph_grp_spec = &( GA_spec->ph_grp_spec );

		for ( i = 0; i < ph_grp_spec->num_photo_specs; i++ ) {
			ph_spec = &( ph_grp_spec->ph_specs[i] );

			if ( ph_spec->area < EPSILON ) {
				ph_spec->area = 1.0;	// default value
			}
			else {
				// area value was assigned a value from the content file
			}
		}
	}
	else if ( typeOfGASpec ( GA_spec ) == PHOTO_VER ) {
		ph_ver_spec = &( GA_spec->ph_ver_spec );

		if ( ph_ver_spec->area < EPSILON ) {
			ph_ver_spec->area = 1.0;	// default value
		}
		else {
			// area value was assigned a value from the content file
		}

		for ( i = 0; i < ph_ver_spec->num_photo_specs; i++ ) {
			ph_spec = &( ph_ver_spec->ph_specs[i] );
			ph_spec->area = ph_ver_spec->area;
		}
	}
	else if ( typeOfGASpec ( GA_spec ) == FIXED_DIM ) {
		// no default value for this type ... we should verify that 
		// the fixed dimensions for each version are positive
		fd_spec = &( GA_spec->fd_spec );

		for ( i = 0; i < fd_spec->num_fd_version_specs; i++ ) {
			fd_ver_spec = &( fd_spec->fd_version_specs[i] );
			if ( ( fd_ver_spec->height < EPSILON ) || ( fd_ver_spec->width < EPSILON ) ) {
				exitOrException("\nfixed dimensions GA has version with negligible dimension");
			}
		}
	}
	else if ( typeOfGASpec ( GA_spec ) == PHOTO_SEQ ) {
		// if an area value was specified, compute the area value 
		// for each ph_spec; 
		// otherwise nothing to do, since each ph_spec->area is already -1.0
		ph_seq_spec = &( GA_spec->ph_seq_spec );

		if ( ph_seq_spec->area < EPSILON ) {
			ph_seq_spec->area = 1.0;
		}
		else {
			// area value was assigned a value from the content file
		}

		for ( i = 0; i < ph_seq_spec->num_photo_specs; i++ ) {
			ph_spec = &( ph_seq_spec->ph_specs[i] );
			ph_spec->area = ph_seq_spec->area / ((double)(ph_seq_spec->num_photo_specs));
		}
	}
	else {
		exitOrException("\nunable to assign area values to photo spec");
	}
}

static void recordAreasFromContentFileTranscript ( struct page_schedule *pg_sched,
												   struct content_file_transcript *cft )
{
	int i;
	struct page_schedule_entry *pse;
	struct graphic_assembly_spec *GA_spec;

	for ( i = 0; i < pg_sched->num_GAs; i++ ) {
		pse = &( pg_sched->pse[i] );
		GA_spec = &( cft->GA_specs[pse->GA_index] );

		if ( pse->GA_index != GA_spec->GA_index ) {
			exitOrException("\nerror recording areas in page schedule entry");
		}

		recordAreasFromGASpec ( pse, GA_spec );
	}
}

static void verifyGASpecsAndGAListLineUp ( struct content_file_transcript *cft,
										   struct graphic_assembly_list *GA_list )
{
	int i;
	struct graphic_assembly *GA;
	struct graphic_assembly_spec *GA_spec;

	if ( cft->num_items != GA_list->num_GAs ) {
		exitOrException("\nunable to verify that GA_list and GA_spec's in CFT line up");
	}

	for ( i = 0; i < GA_list->num_GAs; i++ ) {
		GA = &( GA_list->GA[i] );
		GA_spec = &( cft->GA_specs[i] );

		if ( GA->GA_index != GA_spec->GA_index ) {
			exitOrException("\nunable to verify that GA_list and GA_spec's in CFT line up");
		}

		if ( typeOfGA ( GA ) != GA_spec->type ) {
			exitOrException("\nunable to verify that GA_list and GA_spec's in CFT line up");
		}
	}
}

static void recordAreasFromCollectionSchedule ( struct page_schedule *pg_sched,
												struct content_file_transcript *cft,
												struct graphic_assembly_list *GA_list )
{
	int i;
	struct graphic_assembly_spec *GA_spec;

	// verify that GA_list and the GA_spec's in the CFT "line up" as expected
	//
	// this is not uncalled for since we'll be indexing into the GA_spec's
	// of the CFT using GA_index values from the page schedule entries
	verifyGASpecsAndGAListLineUp ( cft, GA_list );

	// and make it so that each ph_spec has an area value,
	// even when no area value was specified in the content file
	for ( i = 0; i < cft->num_items; i++ ) {
		GA_spec = &( cft->GA_specs[i] );
		assignAreaValuesToPhotoSpecs ( GA_spec );
	}

	recordAreasFromContentFileTranscript ( pg_sched, cft );
}

static int aspectRatioBin ( double aspect )
{
	// this quantizer was selected in a purely ad-hoc way ... here's a brief
	// explanation 
	//
	// mainly, we want to distinguish landscapes from portraits, 
	//	- bin 0 holds landscape 16x9 (aspect 0.56) and other low, wide photos
	//	- bin 1 holds landscape digital slr photos (aspect 0.67) and any landscape 4x3 (aspect 0.75)
	//	- bin 2 holds squarish photos
	//	- bin 3 holds portrait digital slr photos (aspect 1.5) and any portrait 4x3
	//	- bin 4 holds portrait 16x9 and other tall, narrow photos
	//
	// the first threshold (between 0 and 1) is the geometric mean of 0.56 and 0.67
	// the threshold between 1 and 2 is the geometric mean of 0.75 and 1.00
	// the other two thresholds are reciprocals of the two described above

	if ( aspect <  0.613 ) return 0;
	if ( aspect <  0.866 ) return 1;
	if ( aspect <= 1.155 ) return 2;
	if ( aspect <= 1.631 ) return 3;
	return 4;
}

static void generateAspectHistogram ( int *num_photo_GAs, 
									  int *aspect_label, int *max_hist_val, 
									  struct page_schedule *pg_sched,
									  struct graphic_assembly_list *GA_list )
{
	int i, *hist, hist_bin_index, hist_val_sum;
	struct graphic_assembly *GA;
	struct photo *ph;

	hist = new int [ 5 ];

	// make a histogram of the photo GA aspect ratios
	*num_photo_GAs = 0;
	for ( i = 0; i < 5; i++ ) {
		hist[i] = 0;
	}
	for ( i = 0; i < pg_sched->num_GAs; i++ ) {
		GA = ithGAInPageSchedule ( pg_sched, i, GA_list );
		if ( typeOfGA ( GA ) == PHOTO ) {
			(*num_photo_GAs)++;

			ph = &( GA->ph );
			hist_bin_index = aspectRatioBin ( GEAspectFromGAList ( &( ph->GE_ID ), GA_list ) );
			(hist[hist_bin_index])++;
		}
	}

	*aspect_label = *max_hist_val = -1;
	hist_val_sum = 0;
	for ( i = 0; i < 5; i++ ) {
		if ( hist[i] > 0 ) {
			if ( *aspect_label < 0 ) {
				*aspect_label = i;
				*max_hist_val = hist[i];
			}
			else {
				if ( *max_hist_val < hist[i] ) {
					*aspect_label = i;
					*max_hist_val = hist[i];
				}
			}

			hist_val_sum += hist[i];
		}
	}

	// sanity checks 
	if ( *max_hist_val > *num_photo_GAs ) {
		exitOrException("\nerror determining info from aspect ratio histogram");
	}
	if ( hist_val_sum != *num_photo_GAs ) {
		exitOrException("\nerror generating aspect histogram");
	}

	printf("aspect histogram:  ");
	for ( i = 0; i < 5; i++ ) printf("%d ",hist[i]);
	printf(" ; index of max = %d", *aspect_label);
	printf("\n");

	delete [] hist;
}

static int numPhotoGEsInLayout ( struct layout *L, struct graphic_assembly_list *GA_list )
{
	int i, count;
	struct viewport *VP;

	count = 0;
	for ( i = 0; i < L->num_VPs; i++ ) {
		VP = &( L->VPs[i] );
		if ( typeOfGE ( &( VP->GE_ID ), GA_list ) == PHOTO ) {
			count++;
		}
	}

	return ( count );
}

static int numPhotoGAsOnPage ( struct page_schedule *pg_sched,
							   struct graphic_assembly_list *GA_list )
{
	int i, num_photo_GAs;
	struct graphic_assembly *GA;

	num_photo_GAs = 0;
	for ( i = 0; i < pg_sched->num_GAs; i++ ) {
		GA = ithGAInPageSchedule ( pg_sched, i, GA_list );
		if ( typeOfGA ( GA ) == PHOTO ) num_photo_GAs++;
	}

	return ( num_photo_GAs );
}

static int numPhotoGEsOnPage ( struct page_schedule *pg_sched,
							   struct graphic_assembly_list *GA_list )
{
	int i, num_photo_GEs;
	struct graphic_assembly *GA;
	struct photo_grp *ph_grp;
	struct photo_seq *ph_seq;

	num_photo_GEs = 0;
	for ( i = 0; i < pg_sched->num_GAs; i++ ) {
		GA = ithGAInPageSchedule ( pg_sched, i, GA_list );

		if ( typeOfGA ( GA ) == PHOTO ) {
			num_photo_GEs++;
		}
		else if ( typeOfGA ( GA ) == PHOTO_GRP ) {
			ph_grp = &( GA->ph_grp );
			num_photo_GEs += ph_grp->num_photos;
		}
		else if ( typeOfGA ( GA ) == PHOTO_VER ) {
			num_photo_GEs++;
		}
		else if ( typeOfGA ( GA ) == FIXED_DIM ) {
			// does not yield a photo GE
		}
		else if ( typeOfGA ( GA ) == PHOTO_SEQ ) {
			ph_seq = &( GA->ph_seq );
			num_photo_GEs += ph_seq->num_photos;
		}
		else {
			exitOrException("\nerror counting photo GE's on page");
		}
	}

	return ( num_photo_GEs );
}

void removeGAFromPageSchedule ( int GA_index, struct page_schedule *pg_sched )
{
	int new_num_GAs, i;
	struct page_schedule_entry *new_pse, *pse;

	verifyGAIsInPageSchedule ( GA_index, pg_sched );

	if ( pg_sched->num_GAs == 1 ) {
		clearPageSchedule ( pg_sched );
		return;
	}

	// schedule has at least two GA_index's

	new_num_GAs = 0;
	new_pse = new struct page_schedule_entry [ pg_sched->num_GAs - 1 ];
	for ( i = 0; i < pg_sched->num_GAs; i++ ) {
		pse = &( pg_sched->pse[i] );

		if ( pse->GA_index != GA_index ) {
			if ( new_num_GAs >= pg_sched->num_GAs - 1 ) {
				exitOrException("\nerror removing GA from page schedule");
			}

			// initialize the new page schedule entry 
			// so copyPageScheduleEntry will allocate a new array 
			initPageScheduleEntry ( &( new_pse[new_num_GAs] ) );
			copyPageScheduleEntry ( pse, &( new_pse[new_num_GAs] ) );
			new_num_GAs++;
		}
	}

	if ( new_num_GAs != pg_sched->num_GAs - 1 ) {
		exitOrException("\nerror removing GA from page schedule");
	}

	clearPageSchedule ( pg_sched );
	pg_sched->num_GAs = new_num_GAs;
	pg_sched->pse = new_pse;
}

static void verifyGAIsInPageSchedule ( int GA_index, struct page_schedule *pg_sched )
{
	int found;

	if ( GA_index < 0 ) {
		exitOrException("\ninvalid GA_index ... unable to verify GA is in page schedule");
	}
	if ( pg_sched->num_GAs < 0 ) {
		exitOrException("\ninvalid page schedule ... unable to verify GA is in page schedule");
	}

	found = numGAsInPageSchedule ( GA_index, pg_sched );

	if ( found < 1 ) {
		exitOrException("\nGA_index is not in schedule ... unable to verify GA is in page schedule");
	}
	if ( found > 1 ) {
		exitOrException("\nGA_index appears more than once in page schedule");
	}
}

static int numGESchedulesInPageSchedule ( struct page_schedule *pg_sched )
{
	int i, count;
	struct page_schedule_entry *pse;

	count = 0;
	for ( i = 0; i < pg_sched->num_GAs; i++ ) {
		pse = &( pg_sched->pse[i] );
		if ( pse->num_GEs <= 0 ) {
			exitOrException("\nerror counting GE schedules in page schedule");
		}

		count += pse->num_GEs;
	}

	return ( count );
}

static int numPhotoGESchedulesInPageSchedule ( struct page_schedule *pg_sched,
											   struct graphic_assembly_list *GA_list )
{
	int i, GA_index, count;
	struct page_schedule_entry *pse;
	struct graphic_assembly *GA;

	count = 0;
	for ( i = 0; i < pg_sched->num_GAs; i++ ) {
		pse = &( pg_sched->pse[i] );
		GA_index = pse->GA_index;
		GA = &( GA_list->GA[GA_index] );

		if ( typeOfGA ( GA ) != FIXED_DIM ) {
			if ( pse->num_GEs <= 0 ) {
				exitOrException("\nerror counting photo GE schedules in page schedule");
			}
			count += pse->num_GEs;
		}
	}

	return ( count );
}

static int numGAsInPageSchedule ( int GA_index, struct page_schedule *pg_sched )
{
	int i, found;
	struct page_schedule_entry *pse;

	found = 0;
	for ( i = 0; i < pg_sched->num_GAs; i++ ) {
		pse = &( pg_sched->pse[i] );
		if ( GA_index == pse->GA_index ) {
			found++;
		}
	}

	return found;
}

static void verifyGAIsNotInPageSchedule ( int GA_index, struct page_schedule *pg_sched )
{
	int found;

	if ( GA_index < 0 ) {
		exitOrException("\ninvalid GA_index ... unable to verify GA is not in page schedule");
	}
	if ( pg_sched->num_GAs < 0 ) {
		exitOrException("\ninvalid page schedule ... unable to verify GA is not in page schedule");
	}

	found = numGAsInPageSchedule ( GA_index, pg_sched );

	if ( found > 0 ) {
		exitOrException("\nGA_index is in schedule ... unable to verify GA is not in page schedule");
	}
}

static int GAIsNotInPageSchedule ( int GA_index, struct page_schedule *pg_sched )
{
	if ( GA_index < 0 ) {
		exitOrException("\ninvalid GA_index ... unable to verify GA is not in page schedule");
	}
	if ( pg_sched->num_GAs < 0 ) {
		exitOrException("\ninvalid page schedule ... unable to verify GA is not in page schedule");
	}

	if ( numGAsInPageSchedule ( GA_index, pg_sched ) == 0 ) {
		return 1;
	}

	return 0;
}

static int GAIsInPageSchedule ( int GA_index, struct page_schedule *pg_sched )
{
	return ( 1 - GAIsNotInPageSchedule ( GA_index, pg_sched ) );
}

static void sortDoubles ( int N, double *x )
{
	int i, j, min_index;
	double ceiling, min_val, temp;

	// need at least 2 value to sort
	if ( N < 2 ) {
		return;
	}

	ceiling = 0.0;
	for ( i = 0; i < N; i++ ) {
		ceiling += fabs ( x[i] );
	}

	// sort x from least to greatest
	for ( i = 0; i < N - 1; i++ ) {
		// in array x, find the minimum among values after x[i]
		min_val = ceiling + 1.0;
		min_index = -1;
		for ( j = i + 1; j < N; j++ ) {
			if ( min_val > x[j] ) {
				min_val = x[j];
				min_index = j;
			}
		}

		if ( ( min_val > ceiling ) || ( min_index < 0 ) ) {
			exitOrException("\nerror sorting doubles");
		}

		// if the minimum value is less than x[i], swap the two 
		if ( min_val < x[i] ) {
			temp = x[i];
			x[i] = x[min_index];
			x[min_index] = temp;
		}
	}
}

static int indexOfGEIDInGEIDList ( struct GE_identifier *GEID, struct GE_identifier_list *GEID_list )
{
	int i, index;

	index = -1;
	for ( i = 0; i < GEID_list->num_GEIDs; i++ ) {
		if ( GEIDsAreEqual ( GEID, &( GEID_list->GEIDs[i] ) ) ) {
			if ( index < 0 ) {
				index = i;
			}
			else {
				exitOrException("\nerror finding index of GEID in GEID list");
			}
		}
	}

	return ( index );
}

static double averageRelativeArea ( struct page_schedule *pg_sched,
									struct GE_identifier_list *GEID_list )
{
	int i, j, count;
	double sum, average;
	struct page_schedule_entry *pse;
	struct graphic_element_schedule *GE_sched;

	// compute the average of the relative areas of GE's whose ID's appear in the list

	if ( GEID_list->num_GEIDs < 1 ) {
		exitOrException("\nerror computing average relative area");
	}

	count = 0;
	sum = 0.0;
	for ( i = 0; i < pg_sched->num_GAs; i++ ) {
		pse = &( pg_sched->pse[i] );
		for ( j = 0; j < pse->num_GEs; j++ ) {

			GE_sched = &( pse->GE_scheds[j] );
			if ( indexOfGEIDInGEIDList ( &( GE_sched->GE_ID ), GEID_list ) >= 0 ) {
				if ( GE_sched->relative_area < EPSILON ) {
					exitOrException("\nerror computing average relative area");
				}

				sum += GE_sched->relative_area;
				count++;
			}

		}
	}

	if ( count != GEID_list->num_GEIDs ) {
		exitOrException("\nerror computing average relative area");
	}

	average = sum / ((double)count);

	if ( average < EPSILON ) {
		exitOrException("\nerror computing average relative area");
	}

	return ( average );
}

static void populatePageScheduleEntry ( struct graphic_assembly *GA,
										struct page_schedule_entry *pse )
{
	int i;
	struct graphic_element_schedule *GE_sched;
	struct photo *ph;
	struct photo_grp *ph_grp;
	struct photo_grp_photo *ph_grp_ph;
	struct photo_ver *ph_ver;
	struct fixed_dimensions *fd;
	struct fixed_dimensions_version *fd_ver;
	struct photo_seq *ph_seq;

	// for GA's of type PHOTO, there is no information about relative area, 
	// so their relative_area parameters are assigned a value of -1.0
	//
	// for GA's of type FIXED_DIM, we know the ideal area already;
	// their area parameters will be assigned the ideal area value

	pse->GA_index = GA->GA_index;

	if ( typeOfGA ( GA ) == PHOTO ) {
		ph = &(GA->ph);

		pse->num_GEs = 1;
		pse->GE_scheds = new struct graphic_element_schedule [ pse->num_GEs ];

		GE_sched = &( pse->GE_scheds[0] );
		GE_sched->GE_ID = ph->GE_ID;
		GE_sched->relative_area = -1.0;
		GE_sched->target_area = -1.0;
	}
	else if ( typeOfGA ( GA ) == PHOTO_GRP ) {
		ph_grp = &(GA->ph_grp);

		pse->num_GEs = ph_grp->num_photos;
		pse->GE_scheds = new struct graphic_element_schedule [ pse->num_GEs ];

		for ( i = 0; i < pse->num_GEs; i++ ) {
			ph_grp_ph = &( ph_grp->photo_grp_photos[i] );
			GE_sched =  &( pse->GE_scheds[i] );

			GE_sched->GE_ID = ph_grp_ph->GE_ID;
			GE_sched->relative_area = -1.0;
			GE_sched->target_area = -1.0;
		}
	}
	else if ( typeOfGA ( GA ) == PHOTO_VER ) {
		ph_ver = &(GA->ph_ver);

		pse->num_GEs = ph_ver->num_versions;
		pse->GE_scheds = new struct graphic_element_schedule [ pse->num_GEs ];

		for ( i = 0; i < pse->num_GEs; i++ ) {
			ph = &(ph_ver->photos[i]);
			GE_sched = &( pse->GE_scheds[i] );

			GE_sched->GE_ID = ph->GE_ID;
			GE_sched->relative_area = -1.0;
			GE_sched->target_area = -1.0;
		}
	}
	else if ( typeOfGA ( GA ) == FIXED_DIM ) {
		fd = &( GA->fd );

		pse->num_GEs = fd->num_fd_versions;
		pse->GE_scheds = new struct graphic_element_schedule [ pse->num_GEs ];

		for ( i = 0; i < pse->num_GEs; i++ ) {
			fd_ver = &( fd->fd_versions[i] );
			GE_sched = &( pse->GE_scheds[i] );

			GE_sched->GE_ID = fd_ver->GE_ID;
			GE_sched->relative_area = fd_ver->height * fd_ver->width;
			GE_sched->target_area = fd_ver->height * fd_ver->width;
		}
	}
	else if ( typeOfGA ( GA ) == PHOTO_SEQ ) {
		ph_seq = &(GA->ph_seq);

		pse->num_GEs = ph_seq->num_photos;
		pse->GE_scheds = new struct graphic_element_schedule [ pse->num_GEs ];

		for ( i = 0; i < pse->num_GEs; i++ ) {
			ph = &(ph_seq->photos[i]);
			GE_sched = &( pse->GE_scheds[i] );

			GE_sched->GE_ID = ph->GE_ID;
			GE_sched->relative_area = -1.0;
			GE_sched->target_area = -1.0;
		}
	}
	else {
		exitOrException("\nerror populating page schedule entry");
	}
}

void addGAToPageSchedule ( struct graphic_assembly *GA, 
						   struct page_schedule *pg_sched )
{
	struct page_schedule new_pg_sched;
	struct page_schedule_entry *pse;

	verifyGAIsNotInPageSchedule ( GA->GA_index, pg_sched );

	initPageSchedule ( &new_pg_sched, pg_sched->num_GAs + 1 );
	copyPageSchedule ( pg_sched, &new_pg_sched );

	// now populate the new page schedule entry
	pse = &( new_pg_sched.pse[pg_sched->num_GAs] );
	populatePageScheduleEntry ( GA, pse );
	(new_pg_sched.num_GAs)++;

	if ( new_pg_sched.num_GAs != pg_sched->num_GAs + 1 ) {
		exitOrException("\nerror adding GA to page schedule");
	}

	clearPageSchedule ( pg_sched );
	pg_sched->num_GAs = new_pg_sched.num_GAs;
	pg_sched->pse = new_pg_sched.pse;
}

static void addPageScheduleEntryToPageSchedule ( struct page_schedule_entry *incoming_pse, 
												 struct page_schedule *pg_sched )
{
	struct page_schedule new_pg_sched;
	struct page_schedule_entry *new_pse;

	verifyGAIsNotInPageSchedule ( incoming_pse->GA_index, pg_sched );

	initPageSchedule ( &new_pg_sched, pg_sched->num_GAs + 1 );
	copyPageSchedule ( pg_sched, &new_pg_sched );

	// now populate the new page schedule entry
	new_pse = &( new_pg_sched.pse[new_pg_sched.num_GAs] );
	copyPageScheduleEntry ( incoming_pse, new_pse );
	(new_pg_sched.num_GAs)++;

	if ( new_pg_sched.num_GAs != pg_sched->num_GAs + 1 ) {
		exitOrException("\nerror adding GA to page schedule");
	}

	clearPageSchedule ( pg_sched );
	pg_sched->num_GAs = new_pg_sched.num_GAs;
	pg_sched->pse = new_pg_sched.pse;
}

static void checkPageSchedule ( struct page_schedule *pg_sched )
{
	int i, j;
	struct page_schedule_entry *pse;
	struct graphic_element_schedule *GE_sched;

	// for a page schedule to be "complete," 
	// there must be at least one GA;
	// and for each GA, the page schedule entry should have 
	// at least one graphic_element_schedule,
	// and each graphic_element_schedule should have a positive relative area

	if ( pg_sched->num_GAs <= 0 ) {
		exitOrException("\npage schedule is incomplete");
	}

	for ( i = 0; i < pg_sched->num_GAs; i++ ) {
		pse = &( pg_sched->pse[i] );

		if ( pse->GA_index < 0 ) {
			exitOrException("\npage schedule is incomplete");
		}

		if ( pse->num_GEs <= 0 ) {
			exitOrException("\npage schedule is incomplete");
		}

		for ( j = 0; j < pse->num_GEs; j++ ) {
			GE_sched = &( pse->GE_scheds[j] );

			if ( GE_sched->relative_area < EPSILON ) {
				exitOrException("\npage schedule is incomplete");
			}
		}
	}
}

static void initAreaAspectHistogram ( struct twoD_double_array *area_aspect_hist,
									  int max_areas )
{
	int i;
	struct double_list *area_list;

	area_aspect_hist->num_double_lists = 5;
	area_aspect_hist->double_lists = new struct double_list [ 5 ];
	for ( i = 0; i < 5; i++ ) {
		area_list = &( area_aspect_hist->double_lists[i] );
		initDoubleList ( area_list, max_areas );
	}
}

static void initTwoDIntegerArray ( struct twoD_integer_array *twoDIA, int num_integer_lists,
								   int integer_list_length )
{
	int i, j;
	struct integer_list *int_list;

	if ( ( num_integer_lists < 1 ) || ( integer_list_length < 1 ) ) {
		exitOrException("\nerror initializing two-D integer array");
	}

	twoDIA->num_integer_lists = num_integer_lists;
	twoDIA->integer_lists = new struct integer_list [ num_integer_lists ];
	for ( i = 0; i < num_integer_lists; i++ ) {
		int_list = &( twoDIA->integer_lists[i] );
		initIntegerList ( int_list, integer_list_length );

		// set an initial value for every integer in every integer list
		for ( j = 0; j < integer_list_length; j++ ) {
			int_list->integers[j] = -1;
		}
	}
}

static void initGAAspectHistogram ( struct twoD_integer_array *GA_aspect_hist, int max_GAs )
{
	int i;
	struct integer_list *GA_index_list;

	GA_aspect_hist->num_integer_lists = 5;
	GA_aspect_hist->integer_lists = new struct integer_list [ 5 ];
	for ( i = 0; i < 5; i++ ) {
		GA_index_list = &( GA_aspect_hist->integer_lists[i] );
		initIntegerList ( GA_index_list, max_GAs );
	}
}

static void deleteTwoDIntegerArray ( struct twoD_integer_array *twoDIA )
{
	int i;
	struct integer_list *int_list;

	if ( twoDIA->num_integer_lists > 0 ) {
		if ( twoDIA->integer_lists != NULL ) {
			for ( i = 0; i < twoDIA->num_integer_lists; i++ ) {
				int_list= &( twoDIA->integer_lists[i] );
				deleteIntegerList ( int_list );
			}
			delete [] twoDIA->integer_lists;
		}
	}

	twoDIA->num_integer_lists = 0;
	twoDIA->integer_lists = NULL;
}

static void deleteTwoDDoubleArray ( struct twoD_double_array *twoDDA )
{
	int i;
	struct double_list *d_list;

	if ( twoDDA->num_double_lists > 0 ) {
		if ( twoDDA->double_lists != NULL ) {
			for ( i = 0; i < twoDDA->num_double_lists; i++ ) {
				d_list = &( twoDDA->double_lists[i] );
				deleteDoubleList ( d_list );
			}
			delete [] twoDDA->double_lists;
		}
	}

	twoDDA->num_double_lists = 0;
	twoDDA->double_lists = NULL;
}

static int numberIsInIntegerList ( struct integer_list *list, int number )
{
	if ( numberIsNotInIntegerList ( list, number ) ) {
		return 0;
	}

	return 1;
}

static int numberIsNotInIntegerList ( struct integer_list *list, int number )
{
	int i, count;

	if ( number < 0 ) {
		exitOrException("\nunable to verify number is not in list - invalid number");
	}

	count = 0;
	for ( i = 0; i < list->num_integers; i++ ) {
		if ( number == list->integers[i] ) {
			count++;
		}
	}

	if ( ( count != 1 ) && ( count != 0 ) ) {
		exitOrException("\nimproper integer list: did not expect number to appear more than once");
	}

	if ( count == 1 ) {
		return 0;
	}

	return 1;
}

static void verifyNumberIsNotInIntegerList ( struct integer_list *list, int number )
{
	if ( numberIsNotInIntegerList ( list, number ) ) {
		return;
	}

	exitOrException("\nunable to verify number is not in list");
}

static void addNumToDoubleList ( struct double_list *list, double number,
									int position_index )
{
	int i;

	// the position index should be between 0 and list->num_doubles inclusive;
	// that is, we are ONLY allowed to put the new number
	// inside the list, or at the very end 

	if ( ( position_index < 0 ) || ( position_index > list->num_doubles ) ) {
		exitOrException("\nerror putting number into list");
	}

	for ( i = list->num_doubles; i > position_index; i-- ) {
		list->doubles[i] = list->doubles[i-1];
	}
	list->doubles[position_index] = number;

	(list->num_doubles)++;
}

static void addNumToEndOfIntList ( struct integer_list *list, int number )
{
	addNumToIntList ( list, number, list->num_integers );
}

static void addNumToIntList ( struct integer_list *list, int number,
									 int position_index )
{
	int i;

	// the position index should be between 0 and list->num_integers inclusive;
	// that is, we are ONLY allowed to put the new number
	// inside the list, or at the very end 

	if ( ( position_index < 0 ) || ( position_index > list->num_integers ) ) {
		exitOrException("\nerror putting number into list");
	}

	for ( i = list->num_integers; i > position_index; i-- ) {
		list->integers[i] = list->integers[i-1];
	}
	list->integers[position_index] = number;

	(list->num_integers)++;
}

static void addGEIDToGEIDList ( struct GE_identifier_list *list, struct GE_identifier *GEID,
								int position_index )
{
	int i;

	// the position index should be between 0 and list->num_GEIDs inclusive;
	// that is, we are ONLY allowed to put the new item 
	// inside the list, or at the very end 

	if ( ( position_index < 0 ) || ( position_index > list->num_GEIDs ) ) {
		exitOrException("\nerror putting item into list");
	}

	for ( i = list->num_GEIDs; i > position_index; i-- ) {
		list->GEIDs[i] = list->GEIDs[i-1];
	}
	list->GEIDs[position_index] = *GEID;

	(list->num_GEIDs)++;
}

static void jumbleIntegerList ( struct integer_list *list )
{
	int i, num_trials, list_index_1, list_index_2, temp;

	num_trials = 100 * ( list->num_integers );

	for ( i = 0; i < num_trials; i++ ) {
		list_index_1 = pseudoRandomNumber ( list->num_integers - 1 );
		list_index_2 = pseudoRandomNumber ( list->num_integers - 1 );

		if ( list_index_1 != list_index_2 ) {
			temp = list->integers[list_index_1];
			list->integers[list_index_1] = list->integers[list_index_2];
			list->integers[list_index_2] = temp;
		}
	}
}

static void makeGAAspectHistogramFromPageSchedule ( struct page_schedule *pg_sched,
													struct graphic_assembly_list *GA_list, 
													struct twoD_integer_array *GA_aspect_hist )
{
	int i, bin_index;
	struct graphic_assembly *GA;
	struct photo *ph;
	struct integer_list *bin_array;

	// populate the histogram with GA indices
	for ( i = 0;i < pg_sched->num_GAs; i++ ) {
		GA = ithGAInPageSchedule ( pg_sched, i, GA_list );

		if ( typeOfGA ( GA ) == PHOTO ) {
			// determine the histogram bin where we will put GA_index
			ph = &( GA->ph );
			bin_index = aspectRatioBin ( GEAspectFromGAList ( &( ph->GE_ID ), GA_list ) );
			bin_array = &( GA_aspect_hist->integer_lists[bin_index] );

			// add GA to the histogram
			addNumToEndOfIntList ( bin_array, GA->GA_index );
		}
	}

	// jumble the order of elements in each bin array
	for ( i = 0; i < 5; i++ ) {
		bin_array = &( GA_aspect_hist->integer_lists[i] );
		if ( bin_array->num_integers > 1 ) {
			jumbleIntegerList ( bin_array );
		}
	}
}

static void makeInterleavedList ( struct page_schedule *pg_sched,
								  struct twoD_integer_array *GA_aspect_hist,
								  struct integer_list *list )
{
	int i, j, i_num, j_num, temp_int, hist_bin_index, sum;
	int *ordered_indices;
	struct integer_list *bin_array;

	// write down GA_aspect_hist bin indices 
	// from most-populated hist bin index to least-populated hist bin index
	ordered_indices = new int [ 5 ];
	for ( i = 0; i < 5; i++ ) {
		ordered_indices[i] = i;
	}
	for ( i = 0; i < 4; i++ ) {
		for ( j = i+1; j < 5; j++ ) {
			bin_array = &( GA_aspect_hist->integer_lists[ordered_indices[i]] );
			i_num = bin_array->num_integers;

			bin_array = &( GA_aspect_hist->integer_lists[ordered_indices[j]] );
			j_num = bin_array->num_integers;

			if ( j_num > i_num ) {
				temp_int = ordered_indices[i];
				ordered_indices[i] = ordered_indices[j];
				ordered_indices[j] = temp_int;
			}
		}
	}

	// convert the (2-D) histogram into a one-dimensional interleaved list;
	// troll hist bins using the order of hist bin indices determined above
	//
	// here we use pg_sched->num_GAs as the maximum value 
	// of numbers any histogram bin could possibly have
	for ( i = 0; i < pg_sched->num_GAs; i++ ) {
		for ( j = 0; j < 5; j++ ) {
			hist_bin_index = ordered_indices[j];
			bin_array = &( GA_aspect_hist->integer_lists[hist_bin_index] );

			if ( i < bin_array->num_integers ) {
				addNumToEndOfIntList ( list, bin_array->integers[i] );
			}
		}
	}
	// so the first few GA indices in the interleaved list 
	// are photos of different aspect ratio, 
	// with photos of the most-abundant aspect ratios first 

	sum = 0;
	for ( i = 0; i < 5; i++ ) {
		bin_array = &( GA_aspect_hist->integer_lists[i] );
		sum += bin_array->num_integers;
	}
	if ( sum != list->num_integers ) {
		exitOrException("\nerror making interleaved list");
	}

	delete [] ordered_indices;
}

static int numberOfNonemptyIntegerArrays ( struct twoD_integer_array *twoDIA )
{
	int i, count;
	struct integer_list *int_list;

	count = 0;
	for ( i = 0; i < twoDIA->num_integer_lists; i++ ) {
		int_list = &( twoDIA->integer_lists[i] );
		if ( int_list->num_integers > 0 ) {
			count++;
		}
	}

	if ( count <= 0 ) {
		exitOrException("\nexpect at least one nonempty integer array in twoD_integer_array struct");
	}

	return ( count );
}

static void makeAltPageScheduleLists ( struct page_schedule *pg_sched, 
									   struct integer_list *interleaved_photo_GA_index_list,
									   struct integer_list *complete_GA_index_list,
  									   int *num_diff_aspects, 
									   struct graphic_assembly_list *GA_list )
{
	int i;
	struct twoD_integer_array GA_aspect_hist;
	struct page_schedule_entry *pse;

	// make the interleaved list ... the interleaved list contains only PHOTO GA's,
	// and page schedule may have graphic assemblies of other types; 
	// so that length of interleaved list <= length of complete list 
	initGAAspectHistogram ( &GA_aspect_hist, pg_sched->num_GAs );
	makeGAAspectHistogramFromPageSchedule ( pg_sched, GA_list, &GA_aspect_hist );
	*num_diff_aspects = numberOfNonemptyIntegerArrays ( &GA_aspect_hist );
	makeInterleavedList ( pg_sched, &GA_aspect_hist, interleaved_photo_GA_index_list );
	deleteTwoDIntegerArray ( &GA_aspect_hist );

	// make the complete list (all GA indices in the page schedule)
	for ( i = 0; i < pg_sched->num_GAs; i++ ) {
		pse = &( pg_sched->pse[i] );
		addNumToEndOfIntList ( complete_GA_index_list, pse->GA_index );
	}
}

static void recordAreasFromThinAir ( struct page_schedule *pg_sched, int GA_index,
									 struct graphic_assembly_list *GA_list, 
									 double relative_area )
{
	int i, j;
	struct graphic_assembly *GA;
	struct page_schedule_entry *pse;
	struct graphic_element_schedule *GE_sched;

	if ( relative_area < EPSILON ) {
		exitOrException("\ninvalid relative area pulled from thin air");
	}

	verifyGAIsInPageSchedule ( GA_index, pg_sched );

	GA = &( GA_list->GA[GA_index] );
	for ( i = 0; i < pg_sched->num_GAs; i++ ) {
		pse = &( pg_sched->pse[i] );
		if ( pse->GA_index == GA_index ) {
			for ( j = 0; j < pse->num_GEs; j++ ) {
				GE_sched = &( pse->GE_scheds[j] );

				if ( typeOfGA ( GA ) == PHOTO ) {
					GE_sched->relative_area = relative_area;
				}
				else if ( typeOfGA ( GA ) == PHOTO_GRP ) {
					GE_sched->relative_area = relative_area;
				}
				else if ( typeOfGA ( GA ) == PHOTO_VER ) {
					GE_sched->relative_area = relative_area;
				}
				else if ( typeOfGA ( GA ) == FIXED_DIM ) {
					exitOrException("\ndid not expect to assign area to GA of type FIXED_DIM");
				}
				else if ( typeOfGA ( GA ) == PHOTO_SEQ ) {
					GE_sched->relative_area = relative_area / ( ( double ) ( numVisibleGEs(GA) ) );
				}
				else {
					exitOrException("\nerror recording areas from thin air");
				}
			}
		}
	}
}

static void checkAreaDistribution ( int num_GAs, int interleaved_list_len, 
									int num_big, int num_med, int num_small )
{
	if ( num_big > interleaved_list_len ) {
		exitOrException("\nerror in page schedule area distribution");
	}
	if ( ( num_big <= 0 ) || ( num_med < 0 ) || ( num_small < 0 ) ) {
		exitOrException("\nerror in page schedule area distribution");
	}

	if ( num_GAs != num_big + num_med + num_small ) {
		exitOrException("\nerror in page schedule area distribution");
	}
}

static void makeRandomAreaDist ( int num_photo_GAs, int num_GAs,
								 int *num_big, int *num_med, int *num_small )
{
	// the number of photo GA's never should be greater than the number of GA's
	if ( num_photo_GAs > num_GAs ) {
		exitOrException("\nunable to make random area distribution");
	}

	// number of featured photos should be in { 2, ..., num_photo_GAs - 1 }
	if ( num_photo_GAs < 3 ) {
		exitOrException("\nunable to make random area distribution");
	}
	*num_big = 2 + pseudoRandomNumber ( num_photo_GAs - 3 );

	*num_med = num_GAs - ( *num_big );

	*num_small = num_GAs - ( (*num_big) + (*num_med) ); 

	if ( ( *num_big <= 0 ) || ( *num_med < 0 ) || ( *num_small < 0 ) ) {
		exitOrException("\nerror making random area distribution");
	}
}

static void generatePageSchedule ( struct page_schedule *pg_sched,
								   struct integer_list *interleaved_photo_GA_index_list,
								   struct integer_list *complete_GA_index_list, 
								   int marker, int num_big, int num_med, int num_small,
								   struct graphic_assembly_list *GA_list )
{
	int i, list_index, GA_index;
	double relative_area;
	struct graphic_assembly *GA;

	checkAreaDistribution ( complete_GA_index_list->num_integers, 
							interleaved_photo_GA_index_list->num_integers,
							num_big, num_med, num_small );
	initPageSchedule ( pg_sched, 0 );

	// indices of featured GA's are pulled from the interleaved list
	// (this is why num_big must be <= the length of the interleaved list)
	for ( i = 0; i < num_big; i++ ) {
		list_index = ( (marker+i)%(interleaved_photo_GA_index_list->num_integers) );
		GA_index = interleaved_photo_GA_index_list->integers[list_index];
		GA = &( GA_list->GA[GA_index] );
		addGAToPageSchedule ( GA, pg_sched );

		// area value for "big"
		if ( typeOfGA ( GA ) != FIXED_DIM ) {
			relative_area = 4.0;
			recordAreasFromThinAir ( pg_sched, GA_index, GA_list, relative_area );
		}
	}

	// indices of all remaining GA's are pulled from the complete list
	// in no particular order
	jumbleIntegerList ( complete_GA_index_list );
	for ( i = 0; i < complete_GA_index_list->num_integers; i++ ) {
		GA_index = complete_GA_index_list->integers[i];
		GA = &( GA_list->GA[GA_index] );

		if ( GAIsNotInPageSchedule ( GA_index, pg_sched ) ) {
			addGAToPageSchedule ( &(GA_list->GA[GA_index]), pg_sched );

			if ( typeOfGA ( GA ) != FIXED_DIM ) {
				if ( pg_sched->num_GAs < num_big + num_med ) {
					// area value for "med" 
					relative_area = 1.0;
				}
				else {
					// area value for "small"
					relative_area = 0.5;
				}
				recordAreasFromThinAir ( pg_sched, GA_index, GA_list, relative_area );
			}
		}
	}

	checkPageSchedule ( pg_sched );
}

static void generateRandomPageSchedule ( struct page_schedule *pg_sched,
										 struct integer_list *photo_GA_index_list,
										 struct integer_list *complete_GA_index_list, 
										 struct graphic_assembly_list *GA_list )
{
	int i, num_big, num_med, num_small, GA_index;
	double relative_area;
	struct graphic_assembly *GA;

	// decide how many GA's should be big, how many medium, and how many small
	makeRandomAreaDist ( photo_GA_index_list->num_integers, 
						 complete_GA_index_list->num_integers,
						 &num_big, &num_med, &num_small );
	initPageSchedule ( pg_sched, 0 );

	// pull the GA_indices of featured photos from the photo_GA_index_list
	//
	// it is important to jumble the photo_GA_index_list in each trial;
	// if we use the same list over and over,
	// it could limit the variation observed in the random page schedules
	jumbleIntegerList ( photo_GA_index_list );
	for ( i = 0; i < num_big; i++ ) {
		GA_index = photo_GA_index_list->integers[i];
		GA = &( GA_list->GA[GA_index] );
		addGAToPageSchedule ( &(GA_list->GA[GA_index]), pg_sched );

		// area value for "big"
		if ( typeOfGA ( GA ) != FIXED_DIM ) {
			relative_area = 4.0;
			recordAreasFromThinAir ( pg_sched, GA_index, GA_list, relative_area );
		}
	}

	// get all the remaining GA indices from the complete_GA_index_list
	for ( i = 0; i < complete_GA_index_list->num_integers; i++ ) {
		GA_index = complete_GA_index_list->integers[i];
		GA = &( GA_list->GA[GA_index] );

		if ( GAIsNotInPageSchedule ( GA_index, pg_sched ) ) {
			addGAToPageSchedule ( &(GA_list->GA[GA_index]), pg_sched );

			if ( typeOfGA ( GA ) != FIXED_DIM ) {
				if ( pg_sched->num_GAs < num_big + num_med ) {
					// area value for "med" 
					relative_area = 1.0;
				}
				else {
					// area value for "small"
					relative_area = 0.5;
				}
				recordAreasFromThinAir ( pg_sched, GA_index, GA_list, relative_area );
			}
		}
	}

	checkPageSchedule ( pg_sched );
}

static void makeAreaAspectHistogramFromLayout ( struct layout *L,
												struct twoD_double_array *area_aspect_hist )
{
	int i, bin_index;
	double aspect, area;
	struct viewport *VP;
	struct physical_rectangle *p_rect;
	struct double_list *bin_array;

	for ( i = 0; i < L->num_VPs; i++ ) {
		VP = &( L->VPs[i] );
		p_rect = &( VP->p_rect );
		verifyPhysRectDimensions ( p_rect );
		aspect = p_rect->height / p_rect->width;
		area   = p_rect->height * p_rect->width;

		bin_index = aspectRatioBin ( aspect );
		bin_array = &( area_aspect_hist->double_lists[bin_index] );

		// add area to histogram
		addNumToDoubleList ( bin_array, area, bin_array->num_doubles );
	}

	// for each aspect ratio bin, sort the areas from least to greatest
	for ( i = 0; i < area_aspect_hist->num_double_lists; i++ ) {
		bin_array = &( area_aspect_hist->double_lists[i] );
		sortDoubles ( bin_array->num_doubles, bin_array->doubles );
	}
}

static void makeAreaAspectHistogramFromPageSchedule ( struct page_schedule *pg_sched,
													  struct graphic_assembly_list *GA_list, 
													  struct twoD_double_array *area_aspect_hist )
{
	int i, GA_index, bin_index;
	double relative_area;
	struct page_schedule_entry *pse;
	struct graphic_assembly *GA;
	struct photo *ph;
	struct double_list *bin_array;

	for ( i = 0; i < pg_sched->num_GAs; i++ ) {
		pse = &( pg_sched->pse[i] );
		GA_index = pse->GA_index;
		GA = &( GA_list->GA[GA_index] );

		if ( typeOfGA ( GA ) == PHOTO ) {
			relative_area = relativeAreaOfPageScheduleEntry ( pse, GA_list );

			ph = &( GA->ph );
			bin_index = aspectRatioBin ( GEAspectFromGAList ( &( ph->GE_ID ), GA_list ) );
			bin_array = &( area_aspect_hist->double_lists[bin_index] );

			// add relative area of photo to histogram
			addNumToDoubleList ( bin_array, relative_area, bin_array->num_doubles );
		}
	}

	// for each aspect ratio bin, sort the areas from least to greatest
	for ( i = 0; i < area_aspect_hist->num_double_lists; i++ ) {
		bin_array = &( area_aspect_hist->double_lists[i] );
		sortDoubles ( bin_array->num_doubles, bin_array->doubles );
	}
}

static int areaAspectHistogramsAreEqual ( struct twoD_double_array *hist1,
										  struct twoD_double_array *hist2 )
{
	int i, j;
	double area1, area2;
	struct double_list *hist1_bin_array, *hist2_bin_array;

	// for area aspect histograms to be the same,
	// there must be an exact one-to-one correspondence...
	// 
	// this is why sorted the elements in the bin arrays (from least to greatest)

	if ( hist1->num_double_lists != hist2->num_double_lists ) {
		exitOrException("\nunable to compare area aspect histograms");
	}

	for ( i = 0; i < hist1->num_double_lists; i++ ) {
		hist1_bin_array = &( hist1->double_lists[i] );
		hist2_bin_array = &( hist2->double_lists[i] );

		if ( hist1_bin_array->num_doubles != hist2_bin_array->num_doubles ) {
			return ( 0 );
		}

		for ( j = 0; j < hist1_bin_array->num_doubles; j++ ) {
			area1 = hist1_bin_array->doubles[j];
			area2 = hist2_bin_array->doubles[j];

			if ( fabs ( area1 - area2 ) > EPSILON ) {
				return ( 0 );
			}
		}
	}

	return ( 1 );
}

static int areaAspectHistogramsDiffer ( struct twoD_double_array *hist1,
										struct twoD_double_array *hist2 )
{
	if ( areaAspectHistogramsAreEqual ( hist1, hist2 ) ) {
		return ( 0 );
	}

	return ( 1 );
}

static int pageScheduleIsNew ( int num_pages,
							   struct twoD_double_array *area_aspect_hists )
{
	int i;
	struct twoD_double_array *new_area_aspect_hist, *old_area_aspect_hist;

	old_area_aspect_hist = &( area_aspect_hists[num_pages] );
	for ( i = 0; i < num_pages; i++ ) {
		new_area_aspect_hist = &( area_aspect_hists[i] );
		if ( areaAspectHistogramsAreEqual ( old_area_aspect_hist, new_area_aspect_hist ) ) {
			return ( 0 );
		}
	}

	return ( 1 );
}

static void printPageSchedule ( struct page_schedule *pg_sched,
							    struct graphic_assembly_list *GA_list )
{
	int i;
	double relative_area;
	struct page_schedule_entry *pse;

	for ( i = 0; i < pg_sched->num_GAs; i++ ) {
		pse = &( pg_sched->pse[i] );
		relative_area = relativeAreaOfPageScheduleEntry ( pse, GA_list );
		printf("\tGA %d -- relative area %lf\n",pse->GA_index,relative_area);
	}
}

static void printCollectionSchedule ( struct collection_schedule *cs,
									  struct graphic_assembly_list *GA_list )
{
	int i;
	struct page_schedule *pg_sched;

	for ( i = 0; i < cs->num_pages; i++ ) {
		printf("page schedule %d:\n",i);
		pg_sched = &( cs->pg_scheds[i] );

		printPageSchedule ( pg_sched, GA_list );
	}
}

static void makeAltPageSchedules ( struct page_schedule *input_pg_sched,
								   struct collection_schedule *cs, 
								   struct graphic_assembly_list *GA_list,
								   int num_alts )
{
	int i, num_diff_aspects, marker, num_photo_GAs, possible_additional_alts;
	int num_big, num_med, num_small, max_trials, num_trials;
	double x;
	struct integer_list interleaved_photo_GA_index_list, photo_GA_index_list;
	struct integer_list complete_GA_index_list;
	struct twoD_double_array *area_aspect_hists, *area_aspect_hist;
	struct page_schedule *pg_sched;

	initIntegerList ( &interleaved_photo_GA_index_list, input_pg_sched->num_GAs );
	initIntegerList ( &complete_GA_index_list, input_pg_sched->num_GAs );
	makeAltPageScheduleLists ( input_pg_sched, &interleaved_photo_GA_index_list,
							   &complete_GA_index_list, &num_diff_aspects, GA_list );
	marker = 0;

	cs->pg_scheds = new struct page_schedule [ num_alts ];
	cs->num_pages = 0;

	// the first schedule has all equal photo relative areas
	num_big = interleaved_photo_GA_index_list.num_integers;
	num_med = complete_GA_index_list.num_integers - num_big;
	num_small = 0;
	pg_sched = &( cs->pg_scheds[cs->num_pages] );
	generatePageSchedule ( pg_sched, &interleaved_photo_GA_index_list, 
						   &complete_GA_index_list, 
						   marker, num_big, num_med, num_small, GA_list );
	(cs->num_pages)++;
	marker += num_big;

	// each of the following schedules 
	// will feature one photo of a certain aspect ratio
	// 
	// if num_alts < num_diff_aspects 
	// then the schedules should feature the most-abundant aspect ratios
	if ( cs->num_pages < num_alts ) {
		for ( i = 0; i < num_diff_aspects; i++ ) {
			// fix the area distribution
			num_big = 1;
			num_med = complete_GA_index_list.num_integers - num_big;
			num_small = 0;

			// apply the area distribution to the next available page schedule
			pg_sched = &( cs->pg_scheds[cs->num_pages] );
			generatePageSchedule ( pg_sched, &interleaved_photo_GA_index_list, 
								   &complete_GA_index_list, 
								   marker, num_big, num_med, num_small, GA_list );
			(cs->num_pages)++;
			marker += num_big;

			if ( cs->num_pages >= num_alts ) {
				break;
			}
		}
	}

	// if there is room for more page schedules,
	// make additional page schedules that feature more than one photo GA
	//
	// remember, now we have schedules featuring 1 photo GA (above),
	// and in the original call to createPageList, 
	// we made a page that featured all the photos
	//
	// from this point, each additional schedule will have a number 
	// of featured photos from the set F = {2, ..., num_photo_GAs - 1} 
	num_photo_GAs = interleaved_photo_GA_index_list.num_integers;
	if ( ( cs->num_pages < num_alts ) && ( num_photo_GAs > 2 ) ) {
		possible_additional_alts = num_alts - ( cs->num_pages );

		// schedules made in the current if block 
		// will only differ in the number of featured photos,
		// ignoring which aspect ratios are being featured 
		//
		// this reflects the notion that it's more important 
		// to accomodate a variety of numbers of featured photos,
		// than to accomodate a variety of combinations of featured aspect ratios
		// (for a fixed number of featured photos, say); 
		// the reason for implementing according to this notion
		// is that it allows us to have more of the available photos
		// featured in the alternate layouts 

		if ( possible_additional_alts >= num_photo_GAs - 2 ) {
			// make (num_photo_GAs-2) page schedules, one for each number in F
			for ( i = 2; i <= num_photo_GAs - 1; i++ ) {
				num_big = i;
				num_med = complete_GA_index_list.num_integers - num_big;
				num_small = 0;

				// apply the area distribution to the next page schedule 
				pg_sched = &( cs->pg_scheds[cs->num_pages] );
				generatePageSchedule ( pg_sched, &interleaved_photo_GA_index_list, 
									   &complete_GA_index_list, 
									   marker, num_big, num_med, num_small, GA_list );
				(cs->num_pages)++;
				marker += num_big;
			}
		}
		else {
			// select page schedules by sampling the set F as evenly as possible
			for ( i = 1; i <= possible_additional_alts; i++ ) {
				x = ( (double) ((2*i) - 1) );
				x /= ( (double) (2*possible_additional_alts) );
				// if you divide the unit interval 
				// into (possible_additional_alts) bins of equal width,
				// x is the midpoint of the i-th bin 
				// (if you start counting at 0)
				// 
				// now convert x into a number of featured photos;
				// we divide the unit interval
				// into (num_photo_GAs-2) bins of equal width,
				// one bin for each number in the set F,
				// and determine which bin x falls in
				//
				// the step of subtracting EPSILON from x is usually irrelevant,
				// and probably it could be omitted,
				// but it can cause the algorithm to feature fewer photos,
				// which was desirable in some tests
				x *= ( (double) (num_photo_GAs - 2 ) );
				x -= EPSILON;
				num_big = 2 + ( (int) (x) );
				if ( num_big < 2 ) {		// for reasonable numbers of alternates 
					num_big = 2;			// this if block 
				}							// will NEVER be necessary
				num_med = complete_GA_index_list.num_integers - num_big;
				num_small = 0;

				// apply the area distribution to the next page schedule 
				pg_sched = &( cs->pg_scheds[cs->num_pages] );
				generatePageSchedule ( pg_sched, &interleaved_photo_GA_index_list, 
									   &complete_GA_index_list, 
									   marker, num_big, num_med, num_small, GA_list );
				(cs->num_pages)++;
				marker += num_big;
			}
		}
	}

	// if we still want more page schedules, 
	// make some random page schedules 
	// and add them to the collection schedule if they are new
	if ( ( cs->num_pages < num_alts ) && ( num_photo_GAs > 2 ) ) {
		// make a copy of the interleaved list that we can jumble
		initIntegerList ( &photo_GA_index_list, input_pg_sched->num_GAs );
		copyIntegerList ( &interleaved_photo_GA_index_list, &photo_GA_index_list );

		// will need to compare new page schedules against those 
		// that have already made it into the collection schedule,
		// so start a list of area-aspect histograms
		area_aspect_hists = new struct twoD_double_array [ num_alts ];
		for ( i = 0; i < cs->num_pages; i++ ) {
			pg_sched = &( cs->pg_scheds[i] );
			area_aspect_hist = &( area_aspect_hists[i] );
			initAreaAspectHistogram ( area_aspect_hist, pg_sched->num_GAs );
			makeAreaAspectHistogramFromPageSchedule ( pg_sched, GA_list, area_aspect_hist );
		}

		max_trials = 10 * num_alts;
		num_trials = 0;
		while ( ( cs->num_pages < num_alts ) && ( num_trials < max_trials ) ) {
			pg_sched = &( cs->pg_scheds[cs->num_pages] );
			generateRandomPageSchedule ( pg_sched, &photo_GA_index_list, 
										 &complete_GA_index_list, GA_list );
			area_aspect_hist = &( area_aspect_hists[cs->num_pages] );
			initAreaAspectHistogram ( area_aspect_hist, pg_sched->num_GAs );
			makeAreaAspectHistogramFromPageSchedule ( pg_sched, GA_list, area_aspect_hist );

			if ( pageScheduleIsNew ( cs->num_pages, area_aspect_hists ) ) {
				// keep this page schedule
				(cs->num_pages)++;
			}
			else {
				// forget this page schedule
				deleteTwoDDoubleArray ( area_aspect_hist );
			}

			num_trials++;
		}

		for ( i = cs->num_pages - 1; i >= 0 ; i-- ) {
			deleteTwoDDoubleArray ( &( area_aspect_hists[i] ) );
		}
		delete [] area_aspect_hists;
		deleteIntegerList ( &photo_GA_index_list );
	}

	deleteIntegerList ( &complete_GA_index_list );
	deleteIntegerList ( &interleaved_photo_GA_index_list );

	if ( cs->num_pages <= 0 ) {
		exitOrException("\nunable to make an alternate page schedule");
	}
//	printCollectionSchedule ( cs, GA_list );
}

static int numPagesInPageListSequence ( struct page_list_sequence *pls )
{
	int i, count;
	struct page_list *pg_list;

	count = 0; 

	for ( i = 0; i < pls->num_page_lists; i++ ) {
		pg_list = pls->page_lists[i];
		count += pg_list->num_pages;
	}

	return ( count );
}

static int pageIsNotNew ( int num_pages, struct twoD_double_array *area_aspect_hists )
{
	return ( 1 - pageIsNew ( num_pages, area_aspect_hists ) );
}

static int pageIsNew ( int num_pages, struct twoD_double_array *area_aspect_hists )
{
	int i;
	struct twoD_double_array *new_area_aspect_hist, *old_area_aspect_hist;

	new_area_aspect_hist = &( area_aspect_hists[num_pages] );

	for ( i = 0; i < num_pages; i++ ) {
		old_area_aspect_hist = &( area_aspect_hists[i] );
		if ( areaAspectHistogramsAreEqual ( old_area_aspect_hist, new_area_aspect_hist ) ) {
			return ( 0 );
		}
	}

	return ( 1 );
}

static double lowestFixedDimActualToTargetAreaRatio ( struct pbook_page *page, 
													  struct graphic_assembly_list *GA_list )
{
	int i, count;
	double ratio, lowest_ratio;
	struct layout *L;
	struct viewport *VP;
	struct graphic_assembly *GA;

	L = &( page->page_L );

	count = 0;
	for ( i = 0; i < L->num_VPs; i++ ) {
		VP = &( L->VPs[i] );
		GA = GAFromGEID ( &( VP->GE_ID ), GA_list );
		if ( typeOfGA ( GA ) == FIXED_DIM ) {
			ratio = GEActualToTargetAreaRatio ( &( VP->GE_ID ), page, GA_list );

			if ( count < 1 ) {
				lowest_ratio = ratio;
			}
			else {
				if ( lowest_ratio > ratio ) {
					lowest_ratio = ratio;
				}
			}

			count++;
		}
	}

	if ( count < 1 ) {
		exitOrException("\nerror determining fixed_dim actual-to-target area ratio");
	}

	return ( lowest_ratio );
}

static int decideToKeepPage ( struct config_params *cp, int num_pages, 
							  struct twoD_double_array *area_aspect_hists, 
							  struct pbook_page *page, struct graphic_assembly_list *GA_list )
{
	if ( pageIsNotNew ( num_pages, area_aspect_hists ) ) {
		return 0;
	}

	if ( numberOfFixedDimensionsGAs ( &( page->sched ), GA_list ) == 0 ) {
		return 1;
	}

	// there is at least one fixed-dimensions GA on the page;
	// in this case, keep the first two pages that make it this far...
	if ( num_pages < 2 ) {
		return 1;
	}

	// beyond the first two, keep the page only if the region 
	// associated with the fixed-dimensions GA 
	// is large enough compared to its target area
	if ( lowestFixedDimActualToTargetAreaRatio ( page, GA_list ) < cp->FIXED_DIM_DISCARD_THRESHOLD ) {
		return 0;
	}

	return 1;
}

static void selectAltPages ( struct config_params *cp, struct page_list_sequence *pls,
							 struct page_list *output_pg_list, int num_alts, 
							 struct graphic_assembly_list *GA_list )
{
	int h, i, j;
	struct twoD_double_array *area_aspect_hists, *area_aspect_hist;
	struct page_list *pg_list;
	struct pbook_page *page;

	// select at most num_alts pages from the page list sequence
	if ( pls->num_page_lists < 1 ) {
		exitOrException("\nunable to select output page list: zero page lists available");
	}
	if ( num_alts < 1 ) {
		exitOrException("\nunable to select output page list: num_alts must be positive");
	}

	area_aspect_hists = new struct twoD_double_array [ num_alts ];
	output_pg_list->pages = new struct pbook_page [num_alts];
	output_pg_list->num_pages = 0;

	// in each page list, take the first page 
	// that differs from the pages that are already in the output_pg_list
	for ( h = 0; h < num_alts; h++ ) {
		for ( i = 0 ; i < pls->num_page_lists; i++ ) {
			pg_list = pls->page_lists[i];

			for ( j = 0; j < pg_list->num_pages; j++ ) {
				area_aspect_hist = &( area_aspect_hists[output_pg_list->num_pages] );
				page = &( pg_list->pages[j] );

				initAreaAspectHistogram ( area_aspect_hist, page->page_L.num_VPs );
				makeAreaAspectHistogramFromLayout ( &( page->page_L ), area_aspect_hist );

				if ( decideToKeepPage ( cp, output_pg_list->num_pages, area_aspect_hists, page, GA_list ) ) { 
					initPage ( cp, &( output_pg_list->pages[output_pg_list->num_pages] ) );
					duplicatePage ( page, &( output_pg_list->pages[output_pg_list->num_pages] ) );
					(output_pg_list->num_pages)++;
					break;
				}
				else {
					deleteTwoDDoubleArray ( area_aspect_hist );
				}
			}

			if ( output_pg_list->num_pages >= num_alts ) break;
		}

		if ( output_pg_list->num_pages >= num_alts ) break;
	}

	for ( i = output_pg_list->num_pages - 1; i >= 0; i-- ) {
		deleteTwoDDoubleArray ( &( area_aspect_hists[i] ) );
	}
	delete [] area_aspect_hists;
}

void resetSublayoutSpacingValues ( struct config_params *cp,
								   struct graphic_assembly_list *GA_list )
{
	int i;

	for ( i = 0; i < GA_list->num_GAs; i++ ) {
		setSublayoutSpacingValues ( cp, i, GA_list );
	}
}

struct page_list *createAltPages ( struct config_params *cp, 
								   struct graphic_assembly_list *GA_list, 
								   struct page_schedule *input_pg_sched, 
								   int num_alts )
{
	int i;
	struct page_schedule *pg_sched;
	struct collection_schedule cs;
	struct page_list_sequence pls;
	struct page_list *output_pg_list;

	// in this implementation, only GA's of type PHOTO are eligible 
	// to be featured, or specified as "big," on the page; 
	// if necessary, should change code to make it so that all GA types are eligible

	if ( num_alts <= 0 ) {
		exitOrException("\ncreate alt pages: expect request for positive num of alts");
	}
	checkPageSchedule ( input_pg_sched );

	// make page schedules where the featured photos (or photos scheduled to be "big")
	// are unique in (number+(aspect ratios))
	makeAltPageSchedules ( input_pg_sched, &cs, GA_list, num_alts );

	// make layouts according to the page schedules
	pls.num_page_lists = 0;
	pls.page_lists = new struct page_list * [ cs.num_pages ];
	for ( i = 0 ; i < cs.num_pages; i++ ) {
		pg_sched = &( cs.pg_scheds[i] );
		pls.page_lists[i] = createPageList ( cp, GA_list, pg_sched );
		(pls.num_page_lists)++;
	}

	if ( pls.num_page_lists < 1 ) {
		exitOrException("\nerror creating alternate pages: no zero pages were created");
	}

	output_pg_list = new struct page_list [ 1 ];
	selectAltPages ( cp, &pls, output_pg_list, num_alts, GA_list );

	deletePageListSequence ( cp, &pls );
	clearCollectionSchedule ( &cs );

	return ( output_pg_list );
}

static void rectifyPageSchedule ( struct page_schedule *pg_sched, 
								  struct graphic_assembly_list *GA_list )
{
	int i, j;
	double relative_area;
	struct page_schedule_entry *pse;
	struct GE_identifier_list invalid_GEIDs, valid_GEIDs;
	struct graphic_element_schedule *GE_sched;

	if ( ( pg_sched == NULL ) || ( pg_sched->num_GAs <= 0 ) ) {
		return;
	}

	// make a list of the photo GE sched's that have invalid relative areas,
	// and another of the photo GE sched's that have valid relative areas
	initGEIDList ( &invalid_GEIDs, numGESchedulesInPageSchedule ( pg_sched ) );
	initGEIDList ( &valid_GEIDs, numGESchedulesInPageSchedule ( pg_sched ) );
	for ( i = 0; i < pg_sched->num_GAs; i++ ) {
		pse = &( pg_sched->pse[i] );
		for ( j = 0; j < pse->num_GEs; j++ ) {
			GE_sched = &( pse->GE_scheds[j] );
			if ( typeOfGE ( &( GE_sched->GE_ID ), GA_list ) != FIXED_DIM ) {
				// this GE schedule is for a photo GE, so put its identifier into one of the lists
				if ( GE_sched->relative_area < EPSILON ) {
					addGEIDToGEIDList ( &invalid_GEIDs, &( GE_sched->GE_ID ), invalid_GEIDs.num_GEIDs );
				}
				else {
					addGEIDToGEIDList ( &valid_GEIDs, &( GE_sched->GE_ID ), valid_GEIDs.num_GEIDs );
				}
			}
			else {
				if ( GE_sched->relative_area < EPSILON ) {
					// it doesn't make sense to make up a value for this
					exitOrException("\nerror rectifying page schedule");
				}
			}
		}
	}

	// if every graphic element schedule has a valid relative area there is nothing to do
	if ( invalid_GEIDs.num_GEIDs == 0 ) {
		deleteGEIDList ( &valid_GEIDs );
		deleteGEIDList ( &invalid_GEIDs );
		return;
	}

	// determine a relative area value to plug in
	if ( valid_GEIDs.num_GEIDs > 0 ) {
		relative_area = averageRelativeArea ( pg_sched, &valid_GEIDs );
	}
	else {
		relative_area = 1.0;
	}

	for ( i = 0; i < invalid_GEIDs.num_GEIDs; i++ ) {
		GE_sched = GEScheduleFromGEID ( &( invalid_GEIDs.GEIDs[i] ), pg_sched, GA_list );
		GE_sched->relative_area = relative_area;
	}

	deleteGEIDList ( &valid_GEIDs );
	deleteGEIDList ( &invalid_GEIDs );
}

static void reflectLayoutTopToBottom ( struct config_params *cp, struct layout *L )
{
	int i;
	struct config_params temp_cp;
	struct viewport *VP;
	struct physical_rectangle *p_rect;
	double vert_offset, used_height;

	temp_cp = *cp;
	deduceMarginsFromLayout ( &temp_cp, L );

	used_height = temp_cp.pageHeight - temp_cp.topMargin - temp_cp.bottomMargin;
	if ( used_height <= EPSILON ) {
		exitOrException("\nunable to reflect layout top to bottom - expect layout to have positive height");
	}

	for ( i = 0; i < L->num_VPs; i++ ) {
		VP = &( L->VPs[i] );
		p_rect = &( VP->p_rect );

		// determine a new vertical offset for the physical rectangle
		vert_offset = p_rect->vert_offset;
		vert_offset -= temp_cp.bottomMargin;
		vert_offset = used_height - ( p_rect->height ) - vert_offset;
		vert_offset += temp_cp.bottomMargin;

		p_rect->vert_offset = vert_offset;
	}
}

static void reflectLayoutLeftToRight ( struct config_params *cp, struct layout *L )
{
	int i;
	struct config_params temp_cp;
	struct viewport *VP;
	struct physical_rectangle *p_rect;
	double horiz_offset, used_width;

	temp_cp = *cp;
	deduceMarginsFromLayout ( &temp_cp, L );

	used_width = temp_cp.pageWidth - temp_cp.rightMargin - temp_cp.leftMargin;
	if ( used_width <= EPSILON ) {
		exitOrException("\nunable to reflect layout left to right - expect layout to have positive width");
	}

	for ( i = 0; i < L->num_VPs; i++ ) {
		VP = &( L->VPs[i] );
		p_rect = &( VP->p_rect );

		// determine a new vertical offset for the physical rectangle
		horiz_offset = p_rect->horiz_offset;
		horiz_offset -= temp_cp.leftMargin;
		horiz_offset = used_width - ( p_rect->width ) - horiz_offset;
		horiz_offset += temp_cp.leftMargin;

		p_rect->horiz_offset = horiz_offset;
	}
}

void reflectPageTopToBottom ( struct config_params *cp, struct pbook_page *page )
{
	struct subT_treeNode *node;

	if ( page->num_GAs <= 0 ) {
		return;
	}

	// make sure the node at index 0 is the root node
	node = page->page_T;
	if ( node->parent != node->value ) {
		exitOrException("\nexpected node at index zero to be root");
	}

	reflectSubTTreeTopToBottom ( page, page->page_T );
	reflectLayoutTopToBottom ( cp, &( page->page_L ) );
}

void reflectPageLeftToRight ( struct config_params *cp, struct pbook_page *page )
{
	struct subT_treeNode *node;

	if ( page->num_GAs <= 0 ) {
		return;
	}

	// make sure the node at index 0 is the root node
	node = page->page_T;
	if ( node->parent != node->value ) {
		exitOrException("\nexpected node at index zero to be root");
	}

	reflectSubTTreeLeftToRight ( page, page->page_T );
	reflectLayoutLeftToRight ( cp, &( page->page_L ) );
}

static void makePhotoReassignmentLists ( struct pbook_page *page, 
										 struct double_list *VP_area_list,
										 struct integer_list *GA_VP_assignment_list,
										 struct graphic_assembly_list *GA_list )
{
	int i, j, max_index, temp_integer;
	double VP_area, max_val, temp_double;
	struct page_schedule *pg_sched;
	struct graphic_assembly *GA;

	// populate the lists to reflect only GA's that are of type PHOTO
	pg_sched = &( page->sched );
	for ( i = 0; i < pg_sched->num_GAs; i++ ) {
		GA = ithGAInPageSchedule ( pg_sched, i, GA_list );

		if ( typeOfGA ( GA ) == PHOTO ) {
			addNumToEndOfIntList ( GA_VP_assignment_list, GA->GA_index );
			VP_area = GAAreaFromLayout ( GA, &(page->page_L) );
			addNumToDoubleList ( VP_area_list, VP_area, VP_area_list->num_doubles );
		}
	}

	// sort the VP_area_list from greatest area to least area, 
	// and keep the GA_VP_assignment_list in step 
	for ( i = 0; i < VP_area_list->num_doubles - 1; i++ ) {
		max_val = VP_area_list->doubles[i];
		max_index = i;

		for ( j = i + 1; j < VP_area_list->num_doubles; j++ ) {
			if ( max_val < VP_area_list->doubles[j] ) {
				max_val = VP_area_list->doubles[j];
				max_index = j;
			}
		}

		// if max val is greater than VP_area_list->doubles[i], swap
		if ( max_index > i ) {
			temp_double = VP_area_list->doubles[i];
			VP_area_list->doubles[i] = VP_area_list->doubles[max_index];
			VP_area_list->doubles[max_index] = temp_double;

			temp_integer = GA_VP_assignment_list->integers[i];
			GA_VP_assignment_list->integers[i] = GA_VP_assignment_list->integers[max_index];
			GA_VP_assignment_list->integers[max_index] = temp_integer;
		}
	}
}

static int indexOfNumberInIntegerList ( int number, struct integer_list *list )
{
	int i, count, index;

	if ( number < 0 ) {
		exitOrException("\nunable to find number in integer list - invalid number");
	}

	count = 0;
	for ( i = 0; i < list->num_integers; i++ ) {
		if ( number == list->integers[i] ) {
			index = i;
			count++;
		}
	}

	if ( count != 1 ) {
		exitOrException("\nproblem finding number in integer list");
	}

	return ( index );
}

static void makeFirstPossibleSwapList ( struct integer_list *first_swap_GA_list,
										struct integer_list *GA_VP_assignment_list,
										struct double_list *VP_area_list,
										int VP_area_list_position,
										struct graphic_assembly_list *GA_list )
{
	int i, GA_index;
	struct graphic_assembly *curr_GA, *cand_GA;

	GA_index = GA_VP_assignment_list->integers[VP_area_list_position];
	curr_GA = &( GA_list->GA[GA_index] );

	// populate the list with photos that are (1) associated with viewports 
	// that have not yet been processed, and (2) fairly similar in aspect ratio
	// to the photo assigned to the current viewport
	first_swap_GA_list->num_integers = 0;
	for ( i = VP_area_list_position + 1; i < VP_area_list->num_doubles; i++ ) {
		GA_index = GA_VP_assignment_list->integers[i];
		cand_GA = &( GA_list->GA[GA_index] );
		if ( GEsHaveFairlySimilarAspects ( &(curr_GA->ph.GE_ID), &(cand_GA->ph.GE_ID), GA_list ) ) {
			addNumToEndOfIntList ( first_swap_GA_list, GA_index );
		}
	}
}

static void makeSecondPossibleSwapList ( struct pbook_page *page, double curr_rel_area,
										 struct integer_list *first_swap_GA_list,
										 struct integer_list *second_swap_GA_list, 
										 struct graphic_assembly_list *GA_list )
{
	int i, cand_GA_index;
	double cand_rel_area;
	struct graphic_assembly *cand_GA;

	second_swap_GA_list->num_integers = 0;
	for ( i = 0; i < first_swap_GA_list->num_integers; i++ ) {
		cand_GA_index = first_swap_GA_list->integers[i];
		cand_GA = &( GA_list->GA[cand_GA_index] );
		cand_rel_area = photoRelativeAreaFromGA ( cand_GA, page, GA_list );
		if ( cand_rel_area > curr_rel_area + EPSILON ) {
			addNumToEndOfIntList ( second_swap_GA_list, cand_GA_index );
		}
	}
}

static void makeThirdPossibleSwapList ( struct pbook_page *page,
										struct integer_list *second_swap_GA_list,
										struct integer_list *third_swap_GA_list, 
										struct graphic_assembly_list *GA_list )
{
	int i, cand_GA_index;
	double max_rel_area, cand_rel_area;
	struct graphic_assembly *cand_GA;

	// find the maximum relative area among the candidates
	max_rel_area = -1.0;
	for ( i = 0; i < second_swap_GA_list->num_integers; i++ ) {
		cand_GA_index = second_swap_GA_list->integers[i];
		cand_GA = &( GA_list->GA[cand_GA_index] );
		cand_rel_area = photoRelativeAreaFromGA ( cand_GA, page, GA_list );
		if ( max_rel_area < cand_rel_area ) {
			max_rel_area = cand_rel_area;
		}
	}

	third_swap_GA_list->num_integers = 0;
	if ( max_rel_area > EPSILON ) {
		for ( i = 0; i < second_swap_GA_list->num_integers; i++ ) {
			cand_GA_index = second_swap_GA_list->integers[i];
			cand_GA = &( GA_list->GA[cand_GA_index] );
			cand_rel_area = photoRelativeAreaFromGA ( cand_GA, page, GA_list );
			if ( cand_rel_area > max_rel_area - EPSILON ) {
				addNumToEndOfIntList ( third_swap_GA_list, cand_GA_index );
			}
		}
	}
}

static void printIntegerList ( struct integer_list *list )
{
	int i;

	for ( i = 0; i < list->num_integers; i++ ) {
		printf("%d ",list->integers[i]);
	}
	printf("\n");
}

static void reassignPhotosToViewports ( struct config_params *cp,
										struct pbook_page *page,
										struct graphic_assembly_list *GA_list )
{
	int i, curr_GA_index, swap_GA_index, temp_integer, list_index;
	double curr_rel_area;
	struct integer_list GA_VP_assignment_list;
	struct integer_list first_swap_GA_list, second_swap_GA_list, third_swap_GA_list;
	struct double_list VP_area_list;
	struct graphic_assembly *curr_GA;
	struct subT_treeNode *curr_GA_node, *swap_GA_node;

	// make a list of the GA's of type PHOTO in the page schedule;
	// also, make a list of the viewport areas in decreasing order,
	// and a parallel list of GA indices assigned to those viewports
	initDoubleList ( &VP_area_list, page->num_GAs );
	initIntegerList ( &GA_VP_assignment_list, page->num_GAs );
	makePhotoReassignmentLists ( page, &VP_area_list, &GA_VP_assignment_list, GA_list );

	initIntegerList ( &first_swap_GA_list, page->num_GAs );
	initIntegerList ( &second_swap_GA_list, page->num_GAs );
	initIntegerList ( &third_swap_GA_list, page->num_GAs );

	// process viewports in order from largest to smallest
	for ( i = 0; i < VP_area_list.num_doubles - 1; i++ ) {
		// define the "current GA" to be the one assigned to the current viewport 
		curr_GA_index = GA_VP_assignment_list.integers[i];
		curr_GA = &( GA_list->GA[curr_GA_index] );
		curr_rel_area = photoRelativeAreaFromGA ( curr_GA, page, GA_list );

		// make a first list of photo GA's that could be swapped into this viewport,
		// including only those that are (1) associated with viewports 
		// that have not yet been processed, and (2) fairly similar in aspect ratio
		// to the photo assigned to the current viewport
		makeFirstPossibleSwapList ( &first_swap_GA_list, &GA_VP_assignment_list, 
									&VP_area_list, i, GA_list );

		// among the photos in the first list, 
		// throw out any photos that do not have greater relative area than current photo
		makeSecondPossibleSwapList ( page, curr_rel_area, &first_swap_GA_list, 
									 &second_swap_GA_list, GA_list );

		// among the photos that remain, 
		// throw out any GA's that have relative area less than the maximum 
		makeThirdPossibleSwapList ( page, &second_swap_GA_list, 
									&third_swap_GA_list, GA_list );

		// swap the current photo with any photo in the third list
		if ( third_swap_GA_list.num_integers > 0 ) {
			swap_GA_index = third_swap_GA_list.integers[0];

			curr_GA_node = subTTreeNodeFromGAIndex ( page, curr_GA_index );
			swap_GA_node = subTTreeNodeFromGAIndex ( page, swap_GA_index );
			swapGAsInTree ( cp, page, curr_GA_node, swap_GA_node );

			list_index = indexOfNumberInIntegerList(swap_GA_index,&GA_VP_assignment_list);
			temp_integer = GA_VP_assignment_list.integers[i];
			GA_VP_assignment_list.integers[i] = GA_VP_assignment_list.integers[list_index];
			GA_VP_assignment_list.integers[list_index] = temp_integer;
		}

	}

	deleteIntegerList ( &third_swap_GA_list );
	deleteIntegerList ( &second_swap_GA_list );
	deleteIntegerList ( &first_swap_GA_list );

	deleteIntegerList ( &GA_VP_assignment_list );
	deleteDoubleList ( &VP_area_list );

	reflowPage ( cp, page, false, GA_list );
}

struct page_list *createPageList ( struct config_params *cp, 
								   struct graphic_assembly_list *GA_list, 
								   struct page_schedule *pg_sched )
{
	int i;
	struct page_list *pg_list;
	struct pbook_page *page;

	pg_list = new struct page_list [ 1 ];

	// walk through the page schedule; 
	// if any relative area values are invalid, replace with valid values
	rectifyPageSchedule ( pg_sched, GA_list );

	runPageSchedulePlacementTrials ( cp, pg_list, pg_sched, GA_list );

	// optimize the top layout in the list as long as 
	// we don't expect it will take too long (where the expectation 
	// is based on # of images per page)
	page = &( pg_list->pages[0] );
	if ( page->num_GAs <= cp->OPTIMIZE_LAYOUT_PPP_THRESHOLD ) {
		printf("optimizing layout of first layout on page list ...\n");
		optimizeLayout ( cp, page, GA_list );
	}

	// in each page, try to make it so that photo areas
	// follow the order of scheduled relative areas 
	for ( i = 0; i < pg_list->num_pages; i++ ) {
		if ( i == 0 ) printf("reassigning photos in VPs of similar aspect...\n");
		page = &( pg_list->pages[i] );
		reassignPhotosToViewports ( cp, page, GA_list );
	}

	finishLayouts ( cp, pg_list, GA_list );

	return pg_list;
}

static int millisecondValueFromLocalTime ( )
{
/*	SYSTEMTIME st;
	GetLocalTime ( &st );
	return ( st.wMilliseconds );*/
	return 0;
}

static void reportFixedDimensionsResult ( struct pbook_page *page, 
										  struct graphic_assembly_list *GA_list )
{
	int i;
	double height, target_height, width, target_width;
	struct page_schedule *pg_sched;
	struct graphic_assembly *GA;
	struct viewport *VP;
	struct physical_rectangle *p_rect;

	pg_sched = &( page->sched );

	for ( i = 0; i < pg_sched->num_GAs; i++ ) {
		GA = ithGAInPageSchedule ( pg_sched, i, GA_list );

		if ( typeOfGA ( GA ) == FIXED_DIM ) {
			VP = VPFromGAIndex ( GA->GA_index, &( page->page_L ) );
			p_rect = &( VP->p_rect );

			printf("\t\tGA %d: %d-th of %d GA's on page\n",GA->GA_index,i+1,pg_sched->num_GAs);

			height = p_rect->height;
			target_height = GETargetHeight ( &( VP->GE_ID ), &( page->sched ), GA_list );
			width = p_rect->width;
			target_width = GETargetWidth ( &( VP->GE_ID ), &( page->sched ), GA_list );

			printf("\t\tactual/target area = %lf %%\n",100.0*(height*width)/(target_height*target_width));
		}
	}
}

static double photoConsistency ( struct pbook_page *page, 
								 struct graphic_assembly_list *GA_list )
{
	int i, photo_found;
	double area, area_min, area_max;
	struct page_schedule *pg_sched;
	struct graphic_assembly *GA;

	pg_sched = &( page->sched );
	photo_found = 0;
	for ( i = 0; i < pg_sched->num_GAs; i++ ) {
		GA = ithGAInPageSchedule ( pg_sched, i, GA_list );

		if ( typeOfGA ( GA ) == PHOTO ) {
			area = GAAreaFromLayout ( GA, &(page->page_L) );

			if ( photo_found == 0 ) {
				area_min = area_max = area;
				photo_found = 1;
			}
			updateMinAndMax ( area, &area_min, &area_max );
		}
	}

	if ( photo_found == 0 ) {
		exitOrException("\nerror computing photo consistency");
	}

	if ( ( area_min < EPSILON ) || 
		 ( area_max < EPSILON ) || 
		 ( area_min > area_max + EPSILON ) ) {
		exitOrException("\nerror computing consistency score");
	}

	// the returned value is in [0,1]
	return ( area_min / area_max );
}

static double areaOfPhotos ( struct pbook_page *page, 
							 struct graphic_assembly_list *GA_list )
{
	int i;
	double area;
	struct page_schedule *pg_sched;
	struct graphic_assembly *GA;

	pg_sched = &( page->sched );

	area = 0.0;
	for ( i = 0; i < pg_sched->num_GAs; i++ ) {
		GA = ithGAInPageSchedule ( pg_sched, i, GA_list );

		if ( typeOfGA ( GA ) == PHOTO ) {
			area += GAAreaFromLayout ( GA, &( page->page_L ) );
		}
	}

	// normalize the area so the returned value is in [0,1]
	return ( area / ( page->usable_height * page->usable_width ) );
}

static double areaOfSmallestPhoto ( struct pbook_page *page, 
								    struct graphic_assembly_list *GA_list )
{
	int i;
	double min_area, area;
	struct page_schedule *pg_sched;
	struct graphic_assembly *GA;

	pg_sched = &( page->sched );
	min_area = -1.0;
	for ( i = 0; i < pg_sched->num_GAs; i++ ) {
		GA = ithGAInPageSchedule ( pg_sched, i, GA_list );

		if ( typeOfGA ( GA ) == PHOTO ) {
			area = GAAreaFromLayout ( GA, &( page->page_L ) );

			if ( min_area < EPSILON ) {
				min_area = area;
			}
			else {
				if ( min_area > area ) {
					min_area = area;
				}
			}
		}
	}

	return ( min_area );
}

static int indexOfWorstPage ( struct page_list *pg_list,
							  struct graphic_assembly_list *GA_list )
{
	int i, index;
	double area, consistency, min_value, value;
	struct pbook_page *page;

	if ( pg_list->num_pages < 1 ) {
		exitOrException("\nunable to determine lowest scoring page");
	}

	index = -1;
	for ( i = 0; i < pg_list->num_pages; i++ ) {
		page = &( pg_list->pages[i] );
//		value = page->page_L.score;
//		value = areaOfSmallestPhoto ( page, GA_list );
		area = areaOfPhotos ( page, GA_list );
		consistency = photoConsistency ( page, GA_list );
		value = ( 3.0 * area ) + consistency;

		if ( value > EPSILON ) {
			if ( index < 0 ) {
				min_value = value;
				index = i;
			}
			else {
				if ( min_value > value ) {
					min_value = value;
					index = i;
				}
			}
		}
	}

	return ( index );
}

static void removeWorstPages ( struct config_params *cp, struct page_list *pg_list,
							   struct graphic_assembly_list *GA_list )
{
	int num_to_keep, index;

	if ( pg_list->num_pages <= 1 ) return;

	num_to_keep = ( pg_list->num_pages ) / 2;
	if ( num_to_keep * 2 < pg_list->num_pages ) num_to_keep++;	// round up

	if ( ( num_to_keep <= 0 ) || ( num_to_keep >= pg_list->num_pages ) ) {
		exitOrException("\nunable to remove worst pages");
	}

	while ( pg_list->num_pages > num_to_keep ) {
		index = indexOfWorstPage ( pg_list, GA_list );
		if ( index < 0 ) break;

		removePageFromPageList ( cp, &( pg_list->pages[index] ), pg_list );
	}
}

struct page_list *createPage ( struct config_params *cp, 
							   struct graphic_assembly_list *GA_list, 
							   struct page_schedule *pg_sched,
							   int input_counter )
{
	int time_value, index_to_keep, counter;
	struct page_list *pg_list;
	struct pbook_page *page;

	if ( input_counter < 0 ) {
		time_value = millisecondValueFromLocalTime ( );
		// grab a number that is "really" random to select which layout
		// will be shown to the user
		seedPseudoRandomNumber ( time_value );
		counter = pseudoRandomNumber ( cp->ROTATION_CAPACITY - 1 );
		// now put the random number generator back into a predictable state
		seedPseudoRandomNumber ( 1 );
	}
	else {
		counter = input_counter + 1;
	}
	if ( counter < 0 ) {
		exitOrException("\ninvalid counter value");
	}

	if ( decideToDoLayoutRotation ( cp, pg_sched, GA_list ) ) {
		pg_list = createAltPages ( cp, GA_list, pg_sched, cp->ROTATION_CAPACITY );

		if ( input_counter < 0 ) {
			// this is a newpage event and not an "alternates" event; 
			// throw out layouts that are "bad" 
			removeWorstPages ( cp, pg_list, GA_list );
		}
		index_to_keep = counter%(pg_list->num_pages);
	}
	else {
		pg_list = createPageList ( cp, GA_list, pg_sched );
		index_to_keep = 0;
	}

	if ( ( index_to_keep < 0 ) || ( index_to_keep >= pg_list->num_pages ) ) {
		exitOrException("\nerror creating a page");
	}
	printf("index to be retained = %d\n",index_to_keep);

	// delete all pages in the page list except the one we want to keep
	while ( index_to_keep > 0 ) {
		removePageFromPageList ( cp, &( pg_list->pages[0] ), pg_list );
		index_to_keep--;
	}
	while ( pg_list->num_pages > 1 ) {
		removePageFromPageList ( cp, &( pg_list->pages[pg_list->num_pages-1] ), pg_list );
	}
	if ( pg_list->num_pages != 1 ) {
		exitOrException("\nexpected to create exactly one page");
	}

	page = &( pg_list->pages[0] );
	page->rotation_count = counter;

	return pg_list;
}

static int decideToDoLayoutRotation ( struct config_params *cp, 
									  struct page_schedule *pg_sched, 
									  struct graphic_assembly_list *GA_list )
{
	if ( cp->LAYOUT_ROTATION != 1 ) {
		return 0;
	}
	if ( numPhotoGAsOnPage ( pg_sched, GA_list ) < 1 ) {
		return 0;
	}
	if ( numPhotoGAsOnPage ( pg_sched, GA_list ) > cp->ROTATION_PPP_THRESHOLD ) {
		return 0;
	}

	return 1;
}

static void finishLayouts ( struct config_params *cp, struct page_list *pg_list,
						    struct graphic_assembly_list *GA_list )
{
	int i;
	struct pbook_page *page;

	for ( i = 0; i < pg_list->num_pages; i++ ) {
		page = &( pg_list->pages[i] );
		finishPageLayout ( cp, page, GA_list );
	}
}

void initPageSchedule ( struct page_schedule *pg_sched, int num_GAs )
{
	int i;
	struct page_schedule_entry *pse;

	// for a page schedule structure that has not yet been used
	pg_sched->num_GAs = 0;
	pg_sched->pse = NULL;

	// if appropriate, allocate the pse array
	// but clear out all the page schedule entry structures
	if ( num_GAs > 0 ) {
		pg_sched->pse = new struct page_schedule_entry [ num_GAs ];
		for ( i = 0; i < num_GAs; i++ ) {
			pse = &( pg_sched->pse[i] );
			initPageScheduleEntry ( pse );
		}

		// the pse array has been allocated, so it is not NULL;
		// the GE_sched arrays have NOT been allocated, so they are NULL
	}
}

static void initPageScheduleEntry ( struct page_schedule_entry *pse )
{
	pse->GA_index = -1;
	pse->num_GEs = 0;
	pse->GE_scheds = NULL;
}

static void copyPageScheduleEntry ( struct page_schedule_entry *from_pse,
								    struct page_schedule_entry *to_pse )
{
	int i;

	if ( to_pse->GE_scheds == NULL ) {
		if ( from_pse->num_GEs > 0 ) {
			to_pse->GE_scheds = new struct graphic_element_schedule [ from_pse->num_GEs ];
		}
	}

	to_pse->GA_index = from_pse->GA_index;
	to_pse->num_GEs = from_pse->num_GEs;
	for ( i = 0; i < from_pse->num_GEs; i++ ) {
		to_pse->GE_scheds[i] = from_pse->GE_scheds[i];
	}
}

static void copyPageSchedule ( struct page_schedule *from_sched,
							   struct page_schedule *to_sched )
{
	int i;
	struct page_schedule_entry *from_pse, *to_pse;

	// at this point, we expect that if necessary,
	// to_sched->pse is already allocated,
	// but that in each page schedule entry, GE_scheds is set to NULL

	if ( to_sched->pse == NULL ) {
		if ( from_sched->num_GAs > 0 ) {
			exitOrException("\nunable to copy page schedule - did not expect pse to be NULL");
		}
	}

	to_sched->num_GAs = from_sched->num_GAs;
	for ( i = 0; i < from_sched->num_GAs; i++ ) {
		from_pse = &( from_sched->pse[i] );
		to_pse = &( to_sched->pse[i] );

		copyPageScheduleEntry ( from_pse, to_pse );
	}
}


static void makeOnepagePageSequence ( struct config_params *cp, 
									  struct page_sequence *pg_seq,
									  struct page_list_sequence *pls, 
									  int pbook_index, int pbook_page_index )
{
	int page_list_index;
	struct page_list *pg_list;

	if ( pls->num_page_lists <= 0 ) {
		exitOrException("\nempty page list sequence: unable to make onepage page sequence");
	}
	if ( ( pbook_index < 0 ) || ( pbook_index >= cp->NUM_OUTPUT_LAYOUTS ) ) {
		exitOrException("\ninvalid pbook_index: unable to make onepage page sequence");
	}
	if ( ( pbook_page_index < 0 ) || ( pbook_page_index >= pls->num_page_lists ) ) {
		exitOrException("\ninvalid pbook_page_index: unable to make onepage page sequence");
	}

	// page sequence has just one page from one page list
	//
	// page is identified by first getting the pbook_page_index--th page sequence,
	// and in that page sequence, taking the pbook_index--th page 

	pg_list = pls->page_lists[pbook_page_index];
	page_list_index = pbook_index;
	if ( page_list_index >= pg_list->num_pages ) {
		// page list is incomplete; use a page from earlier in the list
		page_list_index = pbook_index%(pg_list->num_pages);
	}

	pg_seq->num_pages = 1;
	pg_seq->pages = new struct pbook_page * [ 1 ];
	pg_seq->pages[0] = &( pg_list->pages[page_list_index] );
}

static void makePageSequence ( struct config_params *cp, struct page_sequence *pg_seq,
							   struct page_list_sequence *pls, int pbook_index )
{
	int i, page_list_index;
	struct page_list *pg_list;

	if ( pls->num_page_lists <= 0 ) {
		exitOrException("\nempty page list sequence: unable to make page sequence");
	}
	if ( ( pbook_index < 0 ) || ( pbook_index >= cp->NUM_OUTPUT_LAYOUTS ) ) {
		exitOrException("\ninvalid pbook_index: unable to make page sequence");
	}

	// page sequence has one page from each page list
	//
	// that is, from each page list in the page list sequence,
	// page sequence takes the page at index pbook_index 

	pg_seq->num_pages = pls->num_page_lists;
	pg_seq->pages = new struct pbook_page * [ pls->num_page_lists ];

	for ( i = 0; i < pls->num_page_lists; i++ ) {
		pg_list = pls->page_lists[i];

		page_list_index = pbook_index;
		if ( page_list_index >= pg_list->num_pages ) {
			// page list is incomplete; use a page from earlier in the list
			page_list_index = pbook_index%(pg_list->num_pages);
		}

		pg_seq->pages[i] = &( pg_list->pages[page_list_index] );
	}
}

static void clearPageSequence ( struct page_sequence *pg_seq )
{
	if ( pg_seq->pages != NULL ) {
		delete [] pg_seq->pages;
	}

	pg_seq->num_pages = 0;
	pg_seq->pages = NULL;
}



static void makeOnepageFilename ( int num_pages, char *pbook_page_filename, 
								  char *pbook_filename, int page_number )
{
	char drive[_MAX_DRIVE];
	char dir[_MAX_DIR];
	char fname[_MAX_FNAME];
	char ext[_MAX_EXT];
	int num_of_zeros;

	_splitpath( pbook_filename, drive, dir, fname, ext );

	if ( num_pages > 1 ) {
		num_of_zeros = 1 + (int) log10 ( (double) ( num_pages - 1 ) );
		sprintf ( fname, "%s.page%%0%dd", fname, num_of_zeros );
		sprintf ( fname, fname, page_number );
	}

	//_makepath ( pbook_page_filename, drive, dir, fname, ext);
}

static void readGraphicAssemblySubtreesState ( FILE *fp, struct graphic_assembly *GA )
{
	int i, j;
	struct GE_treeNode *GE_node;

	fscanf(fp, "%d\n", &(GA->num_subTs));
	if ( GA->num_subTs < 1 ) {
		exitOrException("\nstate reader expects GA to have at least one subT");
	}

	GA->subTs = new struct GE_treeNode * [ GA->num_subTs ];
	for ( i = 0; i < GA->num_subTs; i++ ) {
		GE_node = GA->subTs[i] = new struct GE_treeNode [ treeLen ( numVisibleGEs ( GA ) ) ];
		for ( j = 0; j < treeLen ( numVisibleGEs ( GA ) ); j++ ) {
			readGETreeNodeState ( fp, &( GE_node[j] ) );
		}
	}
}

static void readPageSequenceState ( struct config_params *cp, struct page_sequence *pg_seq, 
									char *filename, struct graphic_assembly_list *GA_list )
{
	FILE *fp;
	int i, j;
	struct graphic_assembly *GA;
	struct photo *ph;
	struct fixed_dimensions *fd;
	struct subT_treeNode *subT_node;
	struct pbook_page *page;

	openStateFile ( filename, &fp, "r" );

	// config params
	readConfigParamsState ( fp, cp );		// OK
	checkConfigValues ( cp );				// OK

	// graphic assembly list 
	GA_list->num_GAs = -1;
	fscanf(fp, "%d\n", &(GA_list->num_GAs));// OK
	if ( GA_list->num_GAs < 0 ) {
		exitOrException("\n1 error reading page sequence state");
	}
	GA_list->GA = new struct graphic_assembly [ GA_list->num_GAs ];

	for ( i = 0; i < GA_list->num_GAs; i++ ) {
		GA = &( GA_list->GA[i] );
		fscanf(fp, "%d\n", &(GA->GA_index));// OK
		fscanf(fp, "%d\n", &(GA->type));	// OK

		if ( typeOfGA ( GA ) == PHOTO ) {
			ph = &( GA->ph );
			readPhotoState ( fp, ph );		// OK 
		}
		else if ( typeOfGA ( GA ) == FIXED_DIM ) {
			fd = &( GA->fd );
			readFixedDimensionsState ( fp, fd );// OK
		}
		else {
			exitOrException("\nstate reader not prepared for GA type");
		}

		readGraphicAssemblySubtreesState ( fp, GA );// OK
	}

	// page(s)
	pg_seq->num_pages = 0;
	fscanf(fp, "%d\n", &(pg_seq->num_pages));	// OK
	if ( pg_seq->num_pages < 1 ) {
		exitOrException("\n2 error reading page sequence state");
	}
	pg_seq->pages = new struct pbook_page * [ pg_seq->num_pages ];
	for ( i = 0; i < pg_seq->num_pages; i++ ) {
		page = pg_seq->pages[i] = new struct pbook_page [ 1 ];

		page->num_GAs = -1;
		fscanf(fp, "%d\n", &(page->num_GAs));	// OK
		if ( page->num_GAs < 0 ) {
			exitOrException("\n3 error reading page sequence state");
		}

		page->page_T = NULL;
		if ( page->num_GAs > 0 ) {
			page->page_T = new struct subT_treeNode [ treeLen ( page->num_GAs ) ];

			for ( j = 0; j < treeLen ( page->num_GAs ); j++ ) {
				subT_node = &( page->page_T[j] );
				readSubTTreeNodeState ( fp, subT_node );	// OK
			}
		}

		readLayoutState ( fp, &( page->page_L ), GA_list );	// OK 
		fscanf(fp, "%lf\n", &(page->usable_height));		// OK
		fscanf(fp, "%lf\n", &(page->usable_width));			// OK
		readPageScheduleState ( fp, &( page->sched ) );		// OK
		fscanf(fp, "%d\n", &(page->rotation_count));		// OK
	}

	fclose(fp);
}

static void writePageSequenceState ( struct config_params *cp, struct page_sequence *pg_seq, 
									 char *filename, struct graphic_assembly_list *GA_list )
{
	FILE *fp;
	int i, j;
	struct graphic_assembly *GA;
	struct photo *ph;
	struct fixed_dimensions *fd;
	struct subT_treeNode *subT_node;
	struct pbook_page *page;

	openStateFile ( filename, &fp, "w" );

	// config params
	writeConfigParamsState ( fp, cp );				// OK 

	// graphic assembly list 
	fprintf(fp, "%d\n", GA_list->num_GAs);			// OK 
	for ( i = 0; i < GA_list->num_GAs; i++ ) {
		GA = &( GA_list->GA[i] );
		fprintf(fp, "%d\n", GA->GA_index);			// OK 
		fprintf(fp, "%d\n", GA->type);				// OK 

		if ( typeOfGA ( GA ) == PHOTO ) {
			ph = &( GA->ph );
			writePhotoState ( fp, ph );				// OK 
		}
		else if ( typeOfGA ( GA ) == FIXED_DIM ) {
			fd = &( GA->fd );
			writeFixedDimensionsState ( fp, fd );	// OK 
		}
		else {
			exitOrException("\nstate writer not prepared for GA type");
		}

		writeGraphicAssemblySubtreesState ( fp, GA );	// OK 
	}

	// page(s)
	fprintf(fp, "%d\n", pg_seq->num_pages);			// OK
	for ( i = 0; i < pg_seq->num_pages; i++ ) {
		page = pg_seq->pages[i];
		fprintf(fp, "%d\n", page->num_GAs);			// OK 

		for ( j = 0; j < treeLen ( page->num_GAs ); j++ ) {
			subT_node = &( page->page_T[j] );
			writeSubTTreeNodeState ( fp, subT_node );	// OK 
		}

		writeLayoutState ( fp, &( page->page_L ), GA_list );// OK
		fprintf(fp, "%lf\n", page->usable_height);	// OK
		fprintf(fp, "%lf\n", page->usable_width);	// OK
		writePageScheduleState ( fp, &( page->sched ) );	// OK
		fprintf(fp, "%d\n", page->rotation_count);	// OK
	}

	fclose(fp);
}

static void readSubTTreeNodeState ( FILE *fp, struct subT_treeNode *node )
{
	fscanf(fp, "%d\n",&(node->value));
	fscanf(fp, "%d\n",&(node->parent));
	fscanf(fp, "%d\n",&(node->Lchild));
	fscanf(fp, "%d\n",&(node->Rchild));
	fscanf(fp, "%d\n",&(node->cut_dir));
	fscanf(fp, "%d\n",&(node->subT_ID.GA_index));
	fscanf(fp, "%d\n",&(node->subT_ID.subT_index));
}

static void writeSubTTreeNodeState ( FILE *fp, struct subT_treeNode *node )
{
	fprintf(fp, "%d\n",node->value);
	fprintf(fp, "%d\n",node->parent);
	fprintf(fp, "%d\n",node->Lchild);
	fprintf(fp, "%d\n",node->Rchild);
	fprintf(fp, "%d\n",node->cut_dir);
	fprintf(fp, "%d\n",node->subT_ID.GA_index);
	fprintf(fp, "%d\n",node->subT_ID.subT_index);
}

static void readGETreeNodeState ( FILE *fp, struct GE_treeNode *node )
{
	fscanf(fp,"%d\n", &(node->value));
	fscanf(fp,"%d\n", &(node->parent));
	fscanf(fp,"%d\n", &(node->Lchild));
	fscanf(fp,"%d\n", &(node->Rchild));
	fscanf(fp,"%d\n", &(node->cut_dir));
	fscanf(fp,"%lf\n", &(node->cut_spacing));
	fscanf(fp,"%lf\n", &(node->border));
	fscanf(fp, "%d\n", &(node->GE_ID.GA_index));
	fscanf(fp, "%d\n", &(node->GE_ID.GE_index));
	fscanf(fp, "%d\n", &(node->GA_index));
//	fscanf(fp, "%lf\n", &(node->bb_a));
//	fscanf(fp, "%lf\n", &(node->bb_e));
}

static void writeGETreeNodeState ( FILE *fp, struct GE_treeNode *node )
{
	fprintf(fp,"%d\n", node->value);
	fprintf(fp,"%d\n", node->parent);
	fprintf(fp,"%d\n", node->Lchild);
	fprintf(fp,"%d\n", node->Rchild);
	fprintf(fp,"%d\n", node->cut_dir);
	fprintf(fp,"%lf\n", node->cut_spacing);
	fprintf(fp,"%lf\n", node->border);
	fprintf(fp, "%d\n", node->GE_ID.GA_index);
	fprintf(fp, "%d\n", node->GE_ID.GE_index);
	fprintf(fp, "%d\n", node->GA_index);
//	fprintf(fp, "%lf\n", node->bb_a);
//	fprintf(fp, "%lf\n", node->bb_e);
}

static void readFixedDimensionsState ( FILE *fp, struct fixed_dimensions *fd )
{
	int i;
	struct fixed_dimensions_version *fd_ver;

	fscanf(fp, "%d\n", &(fd->num_fd_versions));
	if ( fd->num_fd_versions < 1 ) {
		exitOrException("\nexpect at least one version when reading fixed dimensions file");
	}

	fd->fd_versions = new struct fixed_dimensions_version [ fd->num_fd_versions ];
	for ( i = 0; i < fd->num_fd_versions; i++ ) {
		fd_ver = &( fd->fd_versions[i] );

		fscanf(fp, "%d\n", &(fd_ver->GE_ID.GA_index));
		fscanf(fp, "%d\n", &(fd_ver->GE_ID.GE_index));
		fscanf(fp, "%lf\n", &(fd_ver->height));
		fscanf(fp, "%lf\n", &(fd_ver->width));
	}
}

static void readPhotoState ( FILE *fp, struct photo *ph )
{
	int char_count, i_zero;
	char c;

	fscanf(fp, "%d\n", &(ph->GE_ID.GA_index));
	fscanf(fp, "%d\n", &(ph->GE_ID.GE_index));

	ph->filename = new char [ _MAX_FNAME ];
	char_count=0;

	// read the 1st char in the filename
	fscanf(fp,"%c",&c); if ( c == '\n' ) {exitOrException("\nexpected nonempty string for photo filename");}
	ph->filename[char_count++] = c;
	// read the remaining char's in the filename up to newline
	while ( c != '\n' ) {
		fscanf(fp,"%c",&c);
		if ( c != '\n' ) ph->filename[char_count++] = c;
	}
	ph->filename[char_count++] = '\0';

//	ph->filename = new char [ _MAX_FNAME ];
//	fscanf(fp, "%s\n", ph->filename);
//printf("filename is %s\n",ph->filename);

	fscanf(fp, "%d\n", &(ph->height));
	fscanf(fp, "%d\n", &(ph->width));
	fscanf(fp, "%d\n", &(ph->has_crop_region));
	fscanf(fp, "%d\n", &(ph->crop_region.height));
	fscanf(fp, "%d\n", &(ph->crop_region.width));
	fscanf(fp, "%d\n", &(ph->crop_region.vert_offset));
	fscanf(fp, "%d\n", &(ph->crop_region.horiz_offset));
	fscanf(fp, "%d\n", &(ph->has_ROI));
	fscanf(fp, "%d\n", &(ph->ROI.height));
	fscanf(fp, "%d\n", &(ph->ROI.width));
	fscanf(fp, "%d\n", &(ph->ROI.vert_offset));
	fscanf(fp, "%d\n", &(ph->ROI.horiz_offset));
	fscanf(fp, "%d\n", &i_zero);	// fscanf(fp, "%d\n", &(ph->img_obj_num));
}

static void writeGraphicAssemblySubtreesState ( FILE *fp, struct graphic_assembly *GA )
{
	int i, j;
	struct GE_treeNode *GE_node;

	if ( GA->num_subTs < 1 ) {
		exitOrException("\nstate writer expects GA to have at least one subT");
	}
	fprintf(fp, "%d\n", GA->num_subTs);

	for ( i = 0; i < GA->num_subTs; i++ ) {
		GE_node = GA->subTs[i];
		for ( j = 0; j < treeLen ( numVisibleGEs ( GA ) ); j++ ) {
			writeGETreeNodeState ( fp, &( GE_node[j] ) );
		}
	}
}

static void writeFixedDimensionsState ( FILE *fp, struct fixed_dimensions *fd )
{
	int i;
	struct fixed_dimensions_version *fd_ver;

	fprintf(fp, "%d\n", fd->num_fd_versions);

	for ( i = 0; i < fd->num_fd_versions; i++ ) {
		fd_ver = &( fd->fd_versions[i] );

		fprintf(fp, "%d\n", fd_ver->GE_ID.GA_index);
		fprintf(fp, "%d\n", fd_ver->GE_ID.GE_index);
		fprintf(fp, "%lf\n", fd_ver->height);
		fprintf(fp, "%lf\n", fd_ver->width);
	}
}

static void writePhotoState ( FILE *fp, struct photo *ph )
{
	int zero = 0;

	fprintf(fp, "%d\n", ph->GE_ID.GA_index);
	fprintf(fp, "%d\n", ph->GE_ID.GE_index);

	fprintf(fp, "%s\n", ph->filename);

	fprintf(fp, "%d\n", ph->height);
	fprintf(fp, "%d\n", ph->width);
	fprintf(fp, "%d\n", ph->has_crop_region);
	fprintf(fp, "%d\n", ph->crop_region.height);
	fprintf(fp, "%d\n", ph->crop_region.width);
	fprintf(fp, "%d\n", ph->crop_region.vert_offset);
	fprintf(fp, "%d\n", ph->crop_region.horiz_offset);
	fprintf(fp, "%d\n", ph->has_ROI);
	fprintf(fp, "%d\n", ph->ROI.height);
	fprintf(fp, "%d\n", ph->ROI.width);
	fprintf(fp, "%d\n", ph->ROI.vert_offset);
	fprintf(fp, "%d\n", ph->ROI.horiz_offset);
	fprintf(fp, "%d\n", zero);			//	fprintf(fp, "%d\n", ph->img_obj_num);
}

static void readConfigParamsState ( FILE *fp, struct config_params *cp )
{
	int i_zero;
	double d_zero;

	fscanf(fp,"%d\n",&(cp->NUM_OUTPUT_LAYOUTS));
	fscanf(fp,"%d\n",&(cp->NUM_WORKING_LAYOUTS));
	fscanf(fp,"%d\n",&i_zero);					// fscanf(fp,"%d\n",&(cp->AUTO_PAGE_BREAKS));
	fscanf(fp,"%d\n",&i_zero);					// fscanf(fp,"%d\n",&(cp->FIXED_NUM_PAGES));
	fscanf(fp,"%d\n",&i_zero);					// fscanf(fp,"%d\n",&(cp->NUM_PAGES));
	fscanf(fp,"%d\n",&i_zero);					// fscanf(fp,"%d\n",&(cp->MIN_GAPP));
	fscanf(fp,"%d\n",&i_zero);					// fscanf(fp,"%d\n",&(cp->MAX_GAPP));
	fscanf(fp,"%d\n",&i_zero);					// fscanf(fp,"%d\n",&(cp->RANDOMIZE_GAPP));
	fscanf(fp,"%d\n",&(cp->OPTIMIZE_LAYOUT_PPP_THRESHOLD));
	fscanf(fp,"%lf\n",&(cp->FIXED_DIM_DISCARD_THRESHOLD));
	fscanf(fp,"%d\n",&(cp->LAYOUT_ROTATION));
	fscanf(fp,"%d\n",&(cp->ROTATION_CAPACITY));
	fscanf(fp,"%d\n",&(cp->ROTATION_PPP_THRESHOLD));
	fscanf(fp,"%lf\n",&(cp->INTER_GA_SPACING));
	fscanf(fp,"%lf\n",&(cp->PHOTO_SEQ_SPACING));
	fscanf(fp,"%lf\n",&(cp->PHOTO_GRP_SPACING));
	fscanf(fp,"%lf\n",&(cp->BORDER));
	fscanf(fp,"%d\n",&i_zero);					// fscanf(fp,"%d\n",&(cp->RELAX_LAYOUT));
	fscanf(fp,"%lf\n",&d_zero);					// fscanf(fp,"%lf\n",&(cp->ASPECT_FACTOR));
	fscanf(fp,"%lf\n",&d_zero);					// fscanf(fp,"%lf\n",&(cp->MAX_ROTATION));
	fscanf(fp,"%d\n",&(cp->USE_ROI));
	fscanf(fp,"%d\n",&i_zero);					// fscanf(fp,"%d\n",&(cp->SIMPLIFY_PAGE_SCHEDULES));
	fscanf(fp,"%d\n",&i_zero);					// fscanf(fp,"%d\n",&(cp->SIMPLIFY_THRESHOLD));
	fscanf(fp,"%d\n",&i_zero);					// fscanf(fp,"%d\n",&(cp->PDF_OUTPUT));
	fscanf(fp,"%d\n",&i_zero);					// fscanf(fp,"%d\n",&(cp->SINGLE_PDF_OUTPUT));
	fscanf(fp,"%d\n",&(cp->TXT_OUTPUT));
	fscanf(fp,"%lf\n",&(cp->OUTPUT_DPI));
	fscanf(fp,"%d\n",&(cp->CAREFUL_MODE));
	fscanf(fp,"%lf\n",&d_zero);					// fscanf(fp,"%lf\n",&(cp->BACKGROUND_COLOR.RED));
	fscanf(fp,"%lf\n",&d_zero);					// fscanf(fp,"%lf\n",&(cp->BACKGROUND_COLOR.GREEN));
	fscanf(fp,"%lf\n",&d_zero);					// fscanf(fp,"%lf\n",&(cp->BACKGROUND_COLOR.BLUE));
	fscanf(fp,"%lf\n",&d_zero);					// fscanf(fp,"%lf\n",&(cp->BORDER_COLOR.RED));
	fscanf(fp,"%lf\n",&d_zero);					// fscanf(fp,"%lf\n",&(cp->BORDER_COLOR.GREEN));
	fscanf(fp,"%lf\n",&d_zero);					// fscanf(fp,"%lf\n",&(cp->BORDER_COLOR.BLUE));
	fscanf(fp,"%lf\n",&(cp->pageHeight));
	fscanf(fp,"%lf\n",&(cp->pageWidth));
	fscanf(fp,"%lf\n",&(cp->leftMargin));
	fscanf(fp,"%lf\n",&(cp->rightMargin));
	fscanf(fp,"%lf\n",&(cp->topMargin));
	fscanf(fp,"%lf\n",&(cp->bottomMargin));
}

static int doublesDoNotDiffer ( double d1, double d2 )
{
	return ( 1 - doublesDiffer ( d1, d2 ) );
}

static int doublesDiffer ( double d1, double d2 )
{
	double mag, tolerance_factor;

	tolerance_factor = 0.005;

	if ( ( fabs(d1) < EPSILON ) && ( fabs(d2) < EPSILON ) ) {
		return 0;
	}

	if ( ( d1 > 0.0 ) && ( d2 > 0.0 ) ) {
		mag = d1;
		if ( fabs ( d1 - d2 ) < ( tolerance_factor * mag ) ) return 0;
	}

	if ( ( d1 < 0.0 ) && ( d2 < 0.0 ) ) {
		mag = - d1;
		if ( fabs ( d1 - d2 ) < ( tolerance_factor * mag ) ) return 0;
	}

	return 1;
}

static void writeConfigParamsState ( FILE *fp, struct config_params *cp )
{
	int i_zero;
	double d_zero;

	i_zero = 0;
	d_zero = 0.0;

	fprintf(fp,"%d\n",cp->NUM_OUTPUT_LAYOUTS);
	fprintf(fp,"%d\n",cp->NUM_WORKING_LAYOUTS);
	fprintf(fp,"%d\n",i_zero);			// fprintf(fp,"%d\n",cp->AUTO_PAGE_BREAKS);
	fprintf(fp,"%d\n",i_zero);			// fprintf(fp,"%d\n",cp->FIXED_NUM_PAGES);
	fprintf(fp,"%d\n",i_zero);			// fprintf(fp,"%d\n",cp->NUM_PAGES);
	fprintf(fp,"%d\n",i_zero);			// fprintf(fp,"%d\n",cp->MIN_GAPP);
	fprintf(fp,"%d\n",i_zero);			// fprintf(fp,"%d\n",cp->MAX_GAPP);
	fprintf(fp,"%d\n",i_zero);			// fprintf(fp,"%d\n",cp->RANDOMIZE_GAPP);
	fprintf(fp,"%d\n",cp->OPTIMIZE_LAYOUT_PPP_THRESHOLD);
	fprintf(fp,"%lf\n",cp->FIXED_DIM_DISCARD_THRESHOLD);
	fprintf(fp,"%d\n",cp->LAYOUT_ROTATION);
	fprintf(fp,"%d\n",cp->ROTATION_CAPACITY);
	fprintf(fp,"%d\n",cp->ROTATION_PPP_THRESHOLD);
	fprintf(fp,"%lf\n",cp->INTER_GA_SPACING);
	fprintf(fp,"%lf\n",cp->PHOTO_SEQ_SPACING);
	fprintf(fp,"%lf\n",cp->PHOTO_GRP_SPACING);
	fprintf(fp,"%lf\n",cp->BORDER);
	fprintf(fp,"%d\n",i_zero);			// fprintf(fp,"%d\n",cp->RELAX_LAYOUT);
	fprintf(fp,"%lf\n",d_zero);			// fprintf(fp,"%lf\n",cp->ASPECT_FACTOR);
	fprintf(fp,"%lf\n",d_zero);			// fprintf(fp,"%lf\n",cp->MAX_ROTATION);
	fprintf(fp,"%d\n",cp->USE_ROI);
	fprintf(fp,"%d\n",i_zero);			// fprintf(fp,"%d\n",cp->SIMPLIFY_PAGE_SCHEDULES);
	fprintf(fp,"%d\n",i_zero);			// fprintf(fp,"%d\n",cp->SIMPLIFY_THRESHOLD);
	fprintf(fp,"%d\n",i_zero);			// fprintf(fp,"%d\n",cp->PDF_OUTPUT);
	fprintf(fp,"%d\n",i_zero);			// fprintf(fp,"%d\n",cp->SINGLE_PDF_OUTPUT);
	fprintf(fp,"%d\n",cp->TXT_OUTPUT);
	fprintf(fp,"%lf\n",cp->OUTPUT_DPI);
	fprintf(fp,"%d\n",cp->CAREFUL_MODE);
	fprintf(fp,"%lf\n",d_zero);			// fprintf(fp,"%lf\n",cp->BACKGROUND_COLOR.RED);
	fprintf(fp,"%lf\n",d_zero);			// fprintf(fp,"%lf\n",cp->BACKGROUND_COLOR.GREEN);
	fprintf(fp,"%lf\n",d_zero);			// fprintf(fp,"%lf\n",cp->BACKGROUND_COLOR.BLUE);
	fprintf(fp,"%lf\n",d_zero);			// fprintf(fp,"%lf\n",cp->BORDER_COLOR.RED);
	fprintf(fp,"%lf\n",d_zero);			// fprintf(fp,"%lf\n",cp->BORDER_COLOR.GREEN);
	fprintf(fp,"%lf\n",d_zero);			// fprintf(fp,"%lf\n",cp->BORDER_COLOR.BLUE);
	fprintf(fp,"%lf\n",cp->pageHeight);
	fprintf(fp,"%lf\n",cp->pageWidth);
	fprintf(fp,"%lf\n",cp->leftMargin);
	fprintf(fp,"%lf\n",cp->rightMargin);
	fprintf(fp,"%lf\n",cp->topMargin);
	fprintf(fp,"%lf\n",cp->bottomMargin);
}

static void readPageScheduleState ( FILE *fp, struct page_schedule *pg_sched )
{
	int i, j;
	struct page_schedule_entry *pse;
	struct graphic_element_schedule *GE_sched;

	pg_sched->num_GAs = -1;
	fscanf(fp, "%d\n", &(pg_sched->num_GAs));
	if ( pg_sched->num_GAs < 0 ) {
		exitOrException("\nerror reading page schedule state");
	}

	if ( pg_sched->num_GAs > 0 ) {
		pg_sched->pse = new struct page_schedule_entry [ pg_sched->num_GAs ];

		for ( i = 0; i < pg_sched->num_GAs; i++ ) {
			pse = &( pg_sched->pse[i] );

			fscanf(fp, "%d\n", &(pse->GA_index));

			pse->num_GEs = 0;
			fscanf(fp, "%d\n", &(pse->num_GEs));
			if ( pse->num_GEs < 1 ) {
				exitOrException("\nerror reading page schedule state");
			}

			pse->GE_scheds = new struct graphic_element_schedule [ pse->num_GEs ];
			for ( j = 0; j < pse->num_GEs; j++ ) {
				GE_sched = &( pse->GE_scheds[j] );

				fscanf(fp, "%d\n", &(GE_sched->GE_ID.GA_index));
				fscanf(fp, "%d\n", &(GE_sched->GE_ID.GE_index));
				fscanf(fp, "%lf\n", &(GE_sched->relative_area));
				fscanf(fp, "%lf\n", &(GE_sched->target_area));
			}
		}
	}
}

static void writePageScheduleState ( FILE *fp, struct page_schedule *pg_sched )
{
	int i, j;
	struct page_schedule_entry *pse;
	struct graphic_element_schedule *GE_sched;

	fprintf(fp, "%d\n", pg_sched->num_GAs);

	for ( i = 0; i < pg_sched->num_GAs; i++ ) {
		pse = &( pg_sched->pse[i] );

		fprintf(fp, "%d\n", pse->GA_index);
		fprintf(fp, "%d\n", pse->num_GEs);

		for ( j = 0; j < pse->num_GEs; j++ ) {
			GE_sched = &( pse->GE_scheds[j] );

			fprintf(fp, "%d\n", GE_sched->GE_ID.GA_index);
			fprintf(fp, "%d\n", GE_sched->GE_ID.GE_index);
			fprintf(fp, "%lf\n", GE_sched->relative_area);
			fprintf(fp, "%lf\n", GE_sched->target_area);
		}
	}
}

static void readLayoutState ( FILE *fp, struct layout *L,
							  struct graphic_assembly_list *GA_list )
{
	int i;
	struct viewport *VP;

	L->num_VPs = -1;
	fscanf(fp, "%d\n", &(L->num_VPs));

	if ( L->num_VPs < 0 ) {
		exitOrException("\nerror reading layout state");
	}

	L->VPs = NULL;
	if ( L->num_VPs > 0 ) {
		L->VPs = new struct viewport [ L->num_VPs ];

		for ( i = 0; i < L->num_VPs; i++ ) {
			VP = &( L->VPs[i] );

			fscanf(fp, "%lf\n", &(VP->p_rect.height));
			fscanf(fp, "%lf\n", &(VP->p_rect.width));
			fscanf(fp, "%lf\n", &(VP->p_rect.vert_offset));
			fscanf(fp, "%lf\n", &(VP->p_rect.horiz_offset));

			fscanf(fp, "%d\n", &(VP->GE_ID.GA_index));
			fscanf(fp, "%d\n", &(VP->GE_ID.GE_index));

			if ( typeOfGE ( &( VP->GE_ID ), GA_list ) == PHOTO ) {
				fscanf(fp, "%d\n", &(VP->v_rect.height));
				fscanf(fp, "%d\n", &(VP->v_rect.width));
				fscanf(fp, "%d\n", &(VP->v_rect.vert_offset));
				fscanf(fp, "%d\n", &(VP->v_rect.horiz_offset));
			}
			else if ( typeOfGE ( &( VP->GE_ID ), GA_list ) == FIXED_DIM ) {
				// no visible rectangle info to read
			}
			else {
				exitOrException("\nlayout state reader not prepared for GE type");
			}
		}
	}

	fscanf(fp, "%lf\n", &(L->score));
}

static void writeLayoutState ( FILE *fp, struct layout *L, 
							   struct graphic_assembly_list *GA_list )
{
	int i;
	struct viewport *VP;

	fprintf(fp, "%d\n", L->num_VPs);

	for ( i = 0; i < L->num_VPs; i++ ) {
		VP = &( L->VPs[i] );

		fprintf(fp, "%lf\n", VP->p_rect.height);
		fprintf(fp, "%lf\n", VP->p_rect.width);
		fprintf(fp, "%lf\n", VP->p_rect.vert_offset);
		fprintf(fp, "%lf\n", VP->p_rect.horiz_offset);

		fprintf(fp, "%d\n", VP->GE_ID.GA_index);
		fprintf(fp, "%d\n", VP->GE_ID.GE_index);

		if ( typeOfGE ( &( VP->GE_ID ), GA_list ) == PHOTO ) {
			fprintf(fp, "%d\n", VP->v_rect.height);
			fprintf(fp, "%d\n", VP->v_rect.width);
			fprintf(fp, "%d\n", VP->v_rect.vert_offset);
			fprintf(fp, "%d\n", VP->v_rect.horiz_offset);
		}
		else if ( typeOfGE ( &( VP->GE_ID ), GA_list ) == FIXED_DIM ) {
			// no need to write a visible rectangle
		}
		else {
			exitOrException("\nlayout state writer not prepared for GE type");
		}
	}

	fprintf(fp, "%lf\n", L->score);
}






static int totalNumGEs ( struct graphic_assembly_list *GA_list )
{
	int i, count;

	count = 0;
	for ( i = 0; i < GA_list->num_GAs; i++ ) {
		count += numVisibleGEs ( &( GA_list->GA[i] ) );
	}

	return count;
}

static void finishPageLayout ( struct config_params *cp, struct pbook_page *page,
							   struct graphic_assembly_list *GA_list )
{
	struct GE_treeNode *GE_tree;
	struct layout aug_L;

	if ( page->page_L.num_VPs < 1 ) return;

	// we have the viewport physical rectangle areas, now compute their positions 

	GE_tree = new struct GE_treeNode [ treeLen ( page->page_L.num_VPs ) ];
	subTToGE ( cp, GE_tree, page, page->page_L.num_VPs, GA_list );
	FAInitTermNodeBBs ( cp, GE_tree, &( page->page_L ), GA_list );
	FAAccumBBs ( cp, GE_tree, page->page_L.num_VPs, GE_tree[0].value );

	// in the augmented layout, there is one graphic element for each node 
	// in the GE_tree (including interior nodes); in allocRegions we assign
	// a region of space to each "graphic element" in the augmented layout;
	// so in the aug_L, if we are doing strict-area layout, the GE's 
	// that correspond to leaf nodes will have area in general larger than
	// the photos assigned to them ... the purpose of computeObjPositions
	// is to center each photo inside its corresponding cell identified
	// in the augmented layout ... the aug_L is like a layout of regions
	// of space on the page and for leaf nodes the page_L identifies the
	// exact position and dimensions of the photos inside their cells

	// allocate a region to each cell in the graphic element tree
	createAugmentedLayout ( &aug_L, &( page->page_L ), GE_tree, GA_list->num_GAs );
	allocRegions ( cp, page, GE_tree, GA_list, &aug_L, GE_tree[0].value );
	// determine the actual position and size of each viewport physical rectangle
	computeObjPositions ( cp, GE_tree, &( page->page_L ), &aug_L, GA_list );

	// viewport physical rectangles are complete; 
	// now determine viewport visible rectangles
	computeVisibleRectangles ( cp, &( page->page_L ), GA_list );

	clearLayout ( &aug_L );
	delete [] GE_tree;
}

static void computeVisibleRectangles ( struct config_params *cp, struct layout *L, 
									   struct graphic_assembly_list *GA_list )
{
	int i;
	double output_aspect;
	struct viewport *VP;
	struct pixel_rectangle *v_rect;
	struct physical_rectangle *p_rect;
	struct photo *ph;

	for ( i = 0; i < L->num_VPs; i++ ) {
		VP = &( L->VPs[i] );

		v_rect = &( VP->v_rect );
		v_rect->height = v_rect->width = v_rect->vert_offset = v_rect->horiz_offset = 0;

		if ( typeOfGE ( &( VP->GE_ID ), GA_list ) == PHOTO ) {
			// rendered photographic content 
			// should fill exactly the viewport physical rectangle 
			p_rect = &( VP->p_rect );
			if ( ( p_rect->height < EPSILON ) || ( p_rect->width < EPSILON ) ) {
				exitOrException("\ncomputeVisbileRectangles: invalid physical rectangle");
			}
			output_aspect = p_rect->height / p_rect->width;

			ph = photoFromGEID ( &( VP->GE_ID ), GA_list );
			computeVisibleRectangle ( cp, &( VP->v_rect ), output_aspect, ph );
		}
	}
}

static void computeVisibleRectangle ( struct config_params *cp, struct pixel_rectangle *v_rect,
									  double output_aspect, struct photo *ph )
{
	double output_height, output_width;
	double inner_aspect, inner_height, inner_width;
	double outer_aspect, outer_height, outer_width;
	struct pixel_rectangle photo_rect, *ROI, *crop_region;
	struct pixel_rectangle *outer_boundary, *inner_boundary;

	photo_rect.height = ph->height;
	photo_rect.width = ph->width;
	photo_rect.horiz_offset = photo_rect.vert_offset = 0;
	verifyPixelRectangleIsValid ( cp, &photo_rect );

	// verify ROI (if any) is inside crop region (if any) is inside photo
	if ( ph->has_ROI ) {
		ROI = &( ph->ROI );
		verifyPixelRectangleIsValid ( cp, ROI );
		verifyPixelRectanglesAreNested ( cp, ROI, &photo_rect );
	}
	if ( ph->has_crop_region ) {
		crop_region = &( ph->crop_region );
		verifyPixelRectangleIsValid ( cp, crop_region );
		verifyPixelRectanglesAreNested ( cp, crop_region, &photo_rect );
	}
	if ( ( ph->has_ROI ) && ( ph->has_crop_region ) ) {
		verifyPixelRectanglesAreNested ( cp, ROI, crop_region );
	}

	// one of the photo and the crop region are the absolute outer boundary
	// of the visible rectangle
	outer_boundary = &photo_rect;
	if ( ph->has_crop_region ) {
		outer_boundary = crop_region;
	}

	// one of the photo, the crop region and ROI 
	// are the "inner bounds" of the visible rectangle 
	// (kind of; there are circumstances 
	// where this inner boundary must be violated) 
	//
	// note the order of this block of code -- if there is a crop region
	// but not a ROI, then regard the crop region as the inner_boundary
	inner_boundary = &photo_rect;
	if ( ph->has_crop_region ) {
		inner_boundary = crop_region;
	}
	if ( ph->has_ROI ) {
		inner_boundary = ROI;
	}
	verifyPixelRectanglesAreNested ( cp, inner_boundary, outer_boundary );

	inner_height = ( ( double ) ( inner_boundary->height ) );
	inner_width  = ( ( double ) ( inner_boundary->width  ) );
	inner_aspect = inner_height / inner_width; 

	outer_height = ( ( double ) ( outer_boundary->height ) );
	outer_width  = ( ( double ) ( outer_boundary->width  ) );
	outer_aspect = outer_height / outer_width; 

	// if inner boundary aspect is close enough to output_aspect, 
	// just set the visible rectangle to equal the inner boundary
	if ( aspectsAreAboutEqual ( inner_aspect, output_aspect, 0.99 ) ) {
		*v_rect = *inner_boundary;
		return;
	}

	if ( output_aspect > inner_aspect ) {
		if ( output_aspect > outer_height / inner_width ) {
			// the output photo will not include the entire inner boundary
			output_width = outer_height / output_aspect;
		}
		else {
			// the rendered output photo will include the entire inner boundary
			output_width = inner_width;
		}
		output_height = output_aspect * output_width;
	}
	else {
		if ( output_aspect <= inner_height / outer_width ) {
			// the rendered output photo will not include the entire inner boundary
			output_height = outer_width * output_aspect;
		}
		else {
			// the rendered output photo will include the entire inner boundary
			output_height = inner_height;
		}
		output_width = output_height / output_aspect;
	}

	// compute visible rectangle dimensions;
	// force dimensions to be positive and to fit inside the outer boundary
	v_rect->height = ( int ) ( output_height );
	v_rect->width = ( int ) ( output_width );

	if ( v_rect->height < 1 ) {
		v_rect->height = 1;
	}
	if ( v_rect->width < 1 ) {
		v_rect->width = 1;
	}
	if ( v_rect->height > outer_boundary->height ) {
		v_rect->height = outer_boundary->height;
	}
	if ( v_rect->width > outer_boundary->width ) {
		v_rect->width = outer_boundary->width;
	}

	// compute a preliminary visible rectangle position 
	// such that the inner boundary is at its center
	v_rect->vert_offset = inner_boundary->vert_offset;
	v_rect->vert_offset -= ( ( int ) ( 0.5 * ( v_rect->height - inner_boundary->height ) ) );
	v_rect->horiz_offset = inner_boundary->horiz_offset;
	v_rect->horiz_offset -= ( ( int ) ( 0.5 * ( v_rect->width - inner_boundary->width ) ) );

	// if the visible rectangle falls partly outside the available pixels,
	// adjust position as little as necessary such that it falls inside outer_boundary
	if ( v_rect->vert_offset < outer_boundary->vert_offset ) {
		v_rect->vert_offset = outer_boundary->vert_offset;
	}
	if ( v_rect->horiz_offset < outer_boundary->horiz_offset ) {
		v_rect->horiz_offset = outer_boundary->horiz_offset;
	}
	if ( v_rect->vert_offset + v_rect->height > outer_boundary->vert_offset + outer_boundary->height ) {
		v_rect->vert_offset = outer_boundary->vert_offset + outer_boundary->height - v_rect->height;
	}
	if ( v_rect->horiz_offset + v_rect->width > outer_boundary->horiz_offset + outer_boundary->width ) {
		v_rect->horiz_offset = outer_boundary->horiz_offset + outer_boundary->width - v_rect->width;
	}

	verifyPixelRectanglesAreNested ( cp, v_rect, outer_boundary );
}

static int aspectsAreAboutEqual ( double x, double y, double tol )
{
	if ( x < EPSILON ) {
		exitOrException("\naspectsAreAboutEqual: invalid aspect ratio value");
	}
	if ( y < EPSILON ) {
		exitOrException("\naspectsAreAboutEqual: invalid aspect ratio value");
	}

	// tol should be in [0,1] ... think of it like a percentage;
	// tol = 1.0 is zero tolerance, and smaller values give greater tolerance
	if ( ( tol > 1.0 + EPSILON ) || ( tol < 0.9 ) ) {
		exitOrException("\naspectsAreAboutEqual: unexpected tolerance value");
	}

	if ( x < y ) {
		if ( x / y >= tol ) { return 1; }
	}
	else { 
		if ( y / x >= tol ) { return 1; }
	}

	return 0;
}

static void verifyPixelRectanglesAreNested ( struct config_params *cp, 
											 struct pixel_rectangle *inner_rect,
											 struct pixel_rectangle *outer_rect )
{
	// this "if statement" added to reproduce a commenting-out of code 
	// by Mei Zhang around Feb 2008 
	// to allow reflow after replacement with a new image
	if ( cp->CAREFUL_MODE == 1 ) {


		if ( ( inner_rect->height > outer_rect->height ) ||
			 ( inner_rect->width > outer_rect->width ) ) {
			exitOrException("\npixel rectangles should be nested and are not");
		}

		// lower extent of inner should be >= lower extent of outer
		if ( inner_rect->vert_offset < outer_rect->vert_offset ) {
			exitOrException("\npixel rectangles should be nested and are not");
		}

		// leftmost extent of inner should be >= leftmost extent of outer
		if ( inner_rect->horiz_offset < outer_rect->horiz_offset ) {
			exitOrException("\npixel rectangles should be nested and are not");
		}

		// upper extent of inner should be <= upper extent of outer
		if ( inner_rect->vert_offset + inner_rect->height > 
			 outer_rect->vert_offset + outer_rect->height ) {
			exitOrException("\npixel rectangles should be nested and are not");
		}

		// rightmost extent of inner should be <= rightmost extent of outer
		if ( inner_rect->horiz_offset + inner_rect->width > 
			 outer_rect->horiz_offset + outer_rect->width ) {
			exitOrException("\npixel rectangles should be nested and are not");
		}


	}
}

static void printPixelRectangle ( struct pixel_rectangle *rect )
{
	printf("\theight = %d\n",rect->height);
	printf("\twidth = %d\n",rect->width);
	printf("\tvert_offset = %d\n",rect->vert_offset);
	printf("\thoriz_offset = %d\n",rect->horiz_offset);
}

static void verifyPixelRectangleIsValid ( struct config_params *cp, 
										  struct pixel_rectangle *rect )
{
	// this "if statement" added to reproduce a commenting-out of code 
	// by Mei Zhang around Feb 2008 
	// to allow reflow after replacement with a new image
	if ( cp->CAREFUL_MODE == 1 ) {


		if ( ( rect->height < 1 ) || ( rect->width < 1 ) ||
			 ( rect->vert_offset < 0 ) || ( rect->horiz_offset < 0 ) ) {
			exitOrException("\ninvalid pixel rectangle");
		}


	}
}

static void createAugmentedLayout ( struct layout *aug_L, struct layout *L, 
									struct GE_treeNode *GE_tree,
									int interior_node_GA_value )
{
	int i, count;
	struct GE_treeNode *node;
	struct viewport *VP;

	aug_L->num_VPs = treeLen ( L->num_VPs );
	aug_L->VPs = new struct viewport [ aug_L->num_VPs ];

	count = 0;
	for ( i = 0; i < aug_L->num_VPs; i++ ) {
		node = &( GE_tree[i] );
		if ( node->value > 0 ) {
			// copy the entire viewport from the layout in the page structure
			VP = VPFromGEID ( &( node->GE_ID ), L );
			aug_L->VPs[i] = *VP;
		}
		else {
			// pick a "graphic element ID" that doesn't stand for a GE,
			// but that can be used as a unique index into aug_L 
			node->GE_ID.GA_index = interior_node_GA_value;
			node->GE_ID.GE_index = count++;
			aug_L->VPs[i].GE_ID = node->GE_ID;
		}
	}

	if ( count != L->num_VPs - 1 ) {
		exitOrException("\nerror creating augmented layout");
	}

	aug_L->score = L->score;
}

static void computeObjPositions ( struct config_params *cp, 
								  struct GE_treeNode *GE_tree, 
								  struct layout *page_L, 
								  struct layout *aug_L, 
								  struct graphic_assembly_list *GA_list )
{
	int i, index;
	struct GE_treeNode *leaf;
	struct viewport *page_L_VP, *aug_L_VP;
	struct physical_rectangle *page_L_p_rect, *aug_L_p_rect;

	// augmented layout physical rect dimensions are for bounding boxes 
	// and they include extra spacing ... page layout physical rect dimensions 
	// are of graphic elements only - they do not include extra spacing

	for ( i = 0; i < page_L->num_VPs; i++ ) {
		index = GEGetTreeIndex ( GE_tree, treeLen ( page_L->num_VPs ), i+1 );
		leaf = &( GE_tree[index] );

		page_L_VP = VPFromGEID ( &( leaf->GE_ID ), page_L );
		page_L_p_rect = &( page_L_VP->p_rect );
		aug_L_VP = VPFromGEID ( &( leaf->GE_ID ),  aug_L );
		aug_L_p_rect = &( aug_L_VP->p_rect );

		page_L_p_rect->vert_offset = aug_L_p_rect->vert_offset;
		page_L_p_rect->vert_offset += ( 0.5 * ( aug_L_p_rect->height - page_L_p_rect->height ) );
		page_L_p_rect->horiz_offset = aug_L_p_rect->horiz_offset;
		page_L_p_rect->horiz_offset += ( 0.5 * ( aug_L_p_rect->width  - page_L_p_rect->width  ) );
	}
}

static void allocRegions ( struct config_params *cp,
						   struct pbook_page *page, struct GE_treeNode *GE_tree, 
						   struct graphic_assembly_list *GA_list, 
						   struct layout *aug_L, int value )
{
	int index;
	struct GE_treeNode *parent,*Rchild,*Lchild;
	struct viewport *parent_VP, *Rchild_VP, *Lchild_VP;
	struct physical_rectangle *parent_p_rect, *Rchild_p_rect, *Lchild_p_rect;

	index = GEGetTreeIndex ( GE_tree, treeLen ( page->page_L.num_VPs ), value );
	parent = &( GE_tree[index] );
	parent_VP = &( aug_L->VPs[index] );
	parent_p_rect = &( parent_VP->p_rect );

	// if this is the root node, allocate the entire page
	if ( parent->value == parent->parent ) {
		allocPage ( cp, page, GA_list, parent, parent_p_rect ); 
	}

	if ( parent->value > 0 ) { 
		return; 
	}

	index = GEGetTreeIndex ( GE_tree, aug_L->num_VPs, parent->Rchild );
	Rchild = &( GE_tree[index] );
	Rchild_VP = &( aug_L->VPs[index] );
	Rchild_p_rect = &( Rchild_VP->p_rect );

	index = GEGetTreeIndex ( GE_tree, aug_L->num_VPs, parent->Lchild );
	Lchild = &( GE_tree[index] );
	Lchild_VP = &( aug_L->VPs[index] );
	Lchild_p_rect = &( Lchild_VP->p_rect );

	checkContentInfo ( Rchild->bb_a, Rchild->bb_e, Lchild->bb_a, Lchild->bb_e );

	// compute regions for the R and L children

	if ( parent->cut_dir == VERT ) {
		Lchild_p_rect->vert_offset = Rchild_p_rect->vert_offset = parent_p_rect->vert_offset;
		Lchild_p_rect->height = Rchild_p_rect->height = parent_p_rect->height;

		Lchild_p_rect->width = Rchild_p_rect->width = parent_p_rect->width - parent->cut_spacing;
		Lchild_p_rect->width *= ( bbWidth ( Lchild ) / (bbWidth(Lchild)+bbWidth(Rchild)) );
		Rchild_p_rect->width *= ( bbWidth ( Rchild ) / (bbWidth(Lchild)+bbWidth(Rchild)) );

		Lchild_p_rect->horiz_offset = Rchild_p_rect->horiz_offset = parent_p_rect->horiz_offset;
		Rchild_p_rect->horiz_offset += parent->cut_spacing + Lchild_p_rect->width;
	}
	else {
		Lchild_p_rect->horiz_offset = Rchild_p_rect->horiz_offset = parent_p_rect->horiz_offset;
		Lchild_p_rect->width = Rchild_p_rect->width = parent_p_rect->width; 

		Lchild_p_rect->height = Rchild_p_rect->height = parent_p_rect->height - parent->cut_spacing;
		Lchild_p_rect->height *= ( bbHeight ( Lchild ) / (bbHeight(Lchild)+bbHeight(Rchild)) );
		Rchild_p_rect->height *= ( bbHeight ( Rchild ) / (bbHeight(Lchild)+bbHeight(Rchild)) );

		Lchild_p_rect->vert_offset = Rchild_p_rect->vert_offset = parent_p_rect->vert_offset;
		Lchild_p_rect->vert_offset += parent->cut_spacing + Rchild_p_rect->height;
	}

	allocRegions ( cp, page, GE_tree, GA_list, aug_L, parent->Rchild );
	allocRegions ( cp, page, GE_tree, GA_list, aug_L, parent->Lchild );
}

static int nodeIsRootOfSubtree ( struct GE_treeNode *node, struct GE_treeNode *GE_tree,
								 int num_leaves )
{
	int index;
	struct GE_treeNode *parent;

	if ( node->GA_index < 0 ) {
		return 0;
	}

	if ( node->value == node->parent ) {
		return 1;
	}

	index = GEGetTreeIndex ( GE_tree, treeLen ( num_leaves ), node->parent );
	parent = &( GE_tree[index] );

	if ( parent->GA_index < 0 ) {
		return 1;
	}

	if ( parent->GA_index != node->GA_index ) {
		exitOrException("\nerror with GE_tree - GA indices of node and parent are inconsistent");
	}

	return 0;
}


static void allocPage ( struct config_params *cp, struct pbook_page *page, 
					    struct graphic_assembly_list *GA_list, 
					    struct GE_treeNode *root, 
						struct physical_rectangle *p_rect )
{
	// make sure we've got the root
	if ( root->value != root->parent ) {
		exitOrException("\nerror allocating page region: do not have root");
	}
	if ( ( bbHeight ( root ) > page->usable_height + EPSILON ) ||
		 ( bbWidth ( root )  > page->usable_width  + EPSILON ) ) {
		exitOrException("\nroot height (or width) exceeds usable height (or width)");
	}

	// assign writeable area to the root node
	p_rect->height = bbHeight ( root );
	p_rect->width  = bbWidth  ( root );

	p_rect->vert_offset  = cp->bottomMargin + 0.5 * ( page->usable_height - p_rect->height );
	p_rect->horiz_offset = cp->leftMargin + 0.5 * ( page->usable_width - p_rect->width );
}

static void addGARealizationToLayout ( struct layout *L, struct graphic_assembly *GA,
									   struct subT_identifier *subT_ID )
{
	struct layout new_L;
	int count, k;
	struct photo *ph;
	struct photo_grp *ph_grp;
	struct photo_grp_photo *ph_grp_ph;
	struct photo_ver *ph_ver;
	struct fixed_dimensions *fd;
	struct fixed_dimensions_version *fd_ver;
	struct photo_seq *ph_seq;
	struct viewport *VP;

	if ( ( L->num_VPs < 0 ) || ( numVisibleGEs ( GA ) <= 0 ) ) {
		exitOrException("\nerror adding GA to layout listing");
	}
	if ( ( subT_ID->subT_index < 0 ) || ( subT_ID->subT_index >= GA->num_subTs ) ) {
		exitOrException("\ninvalid subtree info - unable to add GA to layout listing");
	}

	// use new_L as a site for effecting a realloc, nothing else
	new_L.VPs = new struct viewport [ L->num_VPs + numVisibleGEs ( GA ) ];
	copyLayout ( L, &new_L );
	if ( L->num_VPs > 0 ) {
		delete [] L->VPs;
	}
	L->VPs = new_L.VPs;

	count = 0;
	if ( typeOfGA ( GA ) == PHOTO ) {
		ph = &( GA->ph );
		VP = &( L->VPs[ (L->num_VPs) + count ] );
		VP->GE_ID = ph->GE_ID;
		count++;
	}
	else if ( typeOfGA ( GA ) == PHOTO_GRP ) {
		ph_grp = &( GA->ph_grp );
		for ( k = 0; k < ph_grp->num_photos; k++ ) {
			ph_grp_ph = &( ph_grp->photo_grp_photos[k] );
			VP = &( L->VPs[ (L->num_VPs) + count ] );
			VP->GE_ID = ph_grp_ph->GE_ID;
			count++;
		}
	}
	else if ( typeOfGA ( GA ) == PHOTO_VER ) {
		ph_ver = &( GA->ph_ver );
		ph = &( ph_ver->photos[subT_ID->subT_index] );
		VP = &( L->VPs[ (L->num_VPs) + count ] );
		VP->GE_ID = ph->GE_ID;
		count++;
	}
	else if ( typeOfGA ( GA ) == FIXED_DIM ) {
		fd = &( GA->fd );
		fd_ver = &( fd->fd_versions[subT_ID->subT_index] );
		VP = &( L->VPs[ (L->num_VPs) + count ] );
		VP->GE_ID = fd_ver->GE_ID;
		count++;
	}
	else if ( typeOfGA ( GA ) == PHOTO_SEQ ) {
		ph_seq = &( GA->ph_seq );
		for ( k = 0; k < ph_seq->num_photos; k++ ) {
			ph = &( ph_seq->photos[k] );
			VP = &( L->VPs[ (L->num_VPs) + count ] );
			VP->GE_ID = ph->GE_ID;
			count++;
		}
	}
	else {exitOrException("\ninvalid GA type");}

	if ( count != numVisibleGEs ( GA ) ) {
		exitOrException("\nerror adding GA to layout listing");
	}

	L->num_VPs += numVisibleGEs ( GA );
}


static int removeGAFromPage ( struct config_params *cp, struct pbook_page *page, 
							    int GA_index, struct graphic_assembly_list *GA_list )
{
	struct graphic_assembly *GA;

	if ( page->num_GAs <= 0 ) {
		exitOrException("\nerror removing GA from page");
	}
	if ( !GAIsOnPage ( page, GA_index ) ) {
		exitOrException("\nGA must be on a page before it can be removed");
	}

	// remove the GA from the page tree
	subTRemoveLeafFromTree ( &( page->page_T ), page->num_GAs, GA_index ); 

	// update the layout list 
	GA = &( GA_list->GA[GA_index] );
	removeGAFromLayout ( &( page->page_L ), GA );

	// decrement the number of GAs on the page
	(page->num_GAs)--;

	return computeObjAreas ( cp, page, GA_list );
}

static int numSubTIndexVectors ( struct page_schedule *pg_sched, struct graphic_assembly_list *GA_list )
{
	int i, num;
	struct graphic_assembly *GA;

	if ( pg_sched->num_GAs < 1 ) {
		exitOrException("\nerror counting subt index vectors");
	}

	num = 1;
	for ( i = 0; i < pg_sched->num_GAs; i++ ) {
		GA = ithGAInPageSchedule ( pg_sched, i, GA_list );

		if ( GA->num_subTs < 1 ) {
			exitOrException("\nerror counting subt index vectors");
		}
		num *= ( GA->num_subTs );
	}

	return ( num );
}

static void generateSubTIndexVectors ( struct page_schedule *pg_sched, 
									   struct twoD_integer_array *subT_index_vecs,
									   struct graphic_assembly_list *GA_list )
{
	int i, j, num_subT_index_vecs, subT_index, counter, counter_ceiling;
	struct graphic_assembly *GA;
	struct integer_list *subT_index_vec;

	num_subT_index_vecs = numSubTIndexVectors ( pg_sched, GA_list );
	initTwoDIntegerArray ( subT_index_vecs, num_subT_index_vecs, pg_sched->num_GAs );

	// each index vector is 1:1 with the page schedule entries
	counter_ceiling = 1;
	for ( i = 0; i < pg_sched->num_GAs; i++ ) {
		GA = ithGAInPageSchedule ( pg_sched, i, GA_list );

		counter = 0;
		subT_index = 0;
		for ( j = 0; j < num_subT_index_vecs; j++ ) {
			subT_index_vec = &( subT_index_vecs->integer_lists[j] );

			if ( subT_index >= GA->num_subTs ) {
				exitOrException("\nerror generating subt index vectors");
			}
			addNumToIntList ( subT_index_vec, subT_index, i );

			counter++;
			if ( counter == counter_ceiling ) {
				counter = 0;
				subT_index++;
				if ( subT_index == GA->num_subTs ) {
					subT_index = 0;
				}
			}
		}

		counter_ceiling *= GA->num_subTs;
	}

	if ( counter_ceiling != num_subT_index_vecs ) {
		exitOrException("\nerror generating subt index vectors");
	}
}

static void plugInSubTIndexVector ( struct pbook_page *page, struct integer_list *subT_index_vec,
									struct graphic_assembly_list *GA_list )
{
	int i;
	struct page_schedule *pg_sched;
	struct graphic_assembly *GA;
	struct subT_treeNode *node;
	struct subT_identifier subT_ID;

	pg_sched = &( page->sched );
	if ( ( pg_sched->num_GAs < 1 ) || ( pg_sched->num_GAs != subT_index_vec->num_integers ) ) {
		exitOrException("\nerror plugging in subt index vector");
	}

	// there must be a direct, 1:1 mapping between the GA's in the page schedule
	// and the subT_tree indices in the vector
	for ( i = 0; i < pg_sched->num_GAs; i++ ) {
		GA = ithGAInPageSchedule ( pg_sched, i, GA_list );
		node = subTTreeNodeFromGAIndex ( page, GA->GA_index );

		subT_ID.GA_index = GA->GA_index;
		subT_ID.subT_index = subT_index_vec->integers[i];

		if ( subTIDsAreNotEqual ( &( node->subT_ID ), &subT_ID ) ) {
			removeGAFromLayout ( &( page->page_L ), GA );
			node->subT_ID = subT_ID;
			addGARealizationToLayout ( &( page->page_L ), GA, &subT_ID );
		}
	}
}

static void setSubTIndices ( struct config_params *cp, struct pbook_page *page,
							 struct graphic_assembly_list *GA_list )
{
	int i, best_subT_index_vec_index;
	struct twoD_integer_array subT_index_vecs;
	struct integer_list *subT_index_vec;
	struct pbook_page scratch_page;

	// generate all the index vectors
	generateSubTIndexVectors ( &( page->sched ), &subT_index_vecs, GA_list );

	// make a scratch page where we can test candidates
	duplicatePage ( page, &scratch_page );

	best_subT_index_vec_index = -1;
	clearScore ();
	for ( i = 0; i < subT_index_vecs.num_integer_lists; i++ ) {
		subT_index_vec = &( subT_index_vecs.integer_lists[i] );
		plugInSubTIndexVector ( &scratch_page, subT_index_vec, GA_list );

		if ( computeObjAreas ( cp, &scratch_page, GA_list ) == PASS ) {
			if ( updateScore ( &scratch_page, NULL, NULL, GA_list ) ) {
				best_subT_index_vec_index = i;
			}
		}
	}
	clearPage ( cp, &scratch_page );

	// use the index vector that yielded the highest score
	if ( best_subT_index_vec_index >= 0 ) {
		subT_index_vec = &( subT_index_vecs.integer_lists[best_subT_index_vec_index] );
		plugInSubTIndexVector ( page, subT_index_vec, GA_list );
	}
	else {
		exitOrException("\nerror setting subT indices");
	}

	deleteTwoDIntegerArray ( &subT_index_vecs );
}

static void setPhotoRelativeAreasFromLayout ( struct pbook_page *page,
											  struct graphic_assembly_list *GA_list )
{
	int i;
	double area;
	struct page_schedule *pg_sched;
	struct graphic_assembly *GA;

	// assign to every page schedule entry a sensible relative area value
	// using the current layout as an 'ideal'
	pg_sched = &( page->sched );
	for ( i = 0; i < pg_sched->num_GAs; i++ ) {
		GA = ithGAInPageSchedule ( pg_sched, i, GA_list );

		if ( typeOfGA(GA)==PHOTO ) {
			area = GAAreaFromLayout ( GA, &(page->page_L) );
			recordAreasFromThinAir ( pg_sched, GA->GA_index, GA_list, area );
		}
		else if ( typeOfGA(GA) != FIXED_DIM ) {
			exitOrException("\nerror setting relative areas from layout: unexpected GA type");
		}
	}
}

int reflowPage ( struct config_params *cp, struct pbook_page *page,
				 bool iterate_GA_presentations,
				 struct graphic_assembly_list *GA_list )
{
	if ( page->num_GAs < 1 ) {
		return PASS; 
	}

	if ( iterate_GA_presentations == true ) {
		if ( oneGAHasMoreThanOnePresentation ( &( page->sched ), GA_list ) ) {
			setSubTIndices ( cp, page, GA_list );
		}
	}

	if ( computeObjAreas ( cp, page, GA_list ) == FAIL ) {
		return FAIL;
	}
	finishPageLayout ( cp, page, GA_list );

	return PASS;
}

static void checkStrictSetDimensionsConditions ( struct pbook_page *page, 
												 struct graphic_assembly *GA,
												 struct graphic_assembly_list *GA_list )
{
	int num_photo_GAs = numPhotoGAsOnPage ( &( page->sched ), GA_list );

	if (  num_photo_GAs == page->num_GAs ) return; 

	if ( num_photo_GAs == page->num_GAs - 1 ) {
		if ( typeOfGA ( GA ) == FIXED_DIM ) return;
	}

	exitOrException("\nexpect all GA's to be type PHOTO, or all but one with selected GA type FIXED_DIM");
}

int setDimensions ( struct config_params *cp, struct pbook_page *page, 
					int GA_index, double height, double width,
					struct graphic_assembly_list *GA_list )
{
	struct graphic_assembly *GA;

	// preliminary error checks 
	if ( page->num_GAs < 2 ) {
		exitOrException("\nneed at least two GA's on page in order to set dimensions\n");
	}
	if ( ( GA_index < 0 ) || ( GA_index >= GA_list->num_GAs ) ) {
		exitOrException("\nerror when setting dimensions ... invalid GA_index");
	}
	GA = & ( GA_list->GA[GA_index] );
	if ( GA->num_subTs <= 0 ) {
		exitOrException("\nerror when setting dimensions");
	}
	if ( !GAIsOnPage ( page, GA_index ) ) {
		exitOrException("\nunable to set dimensions since the GA is not on the page");
	}
	if ( ( height < EPSILON ) || ( width < EPSILON ) ) {
		exitOrException("\ninvalid height or width");
	}
	if ( height > page->usable_height + EPSILON ) {
		exitOrException("\nunable to set height greater than usable height on page");
	}
	if ( width > page->usable_width + EPSILON ) {
		exitOrException("\nunable to set width greater than usable width on page");
	}

	// a few stricter error checks
	checkStrictSetDimensionsConditions ( page, GA, GA_list );

	// now try to set the dimensions of the GA
	return ( tryToSetDimensions ( cp, page, GA, height, width, GA_list ) );
}

static void clearROIs ( struct config_params *cp, struct pbook_page *page, 
						struct graphic_assembly_list *GA_list )
{
	int i;
	struct layout *L;
	struct viewport *VP;
	struct photo *ph;

	L = &( page->page_L );
	if ( L->num_VPs <= 0 ) {
		exitOrException("\nerror clearing ROI's ... expect at least one viewport on page");
	}

	for ( i = 0; i < L->num_VPs; i++ ) {
		VP = &( L->VPs[i] );
		if ( typeOfGE ( &( VP->GE_ID ), GA_list ) == PHOTO ) {
			ph = photoFromGEID ( &( VP->GE_ID ), GA_list );
			ph->has_ROI = 0;
		}
	}
}

static void plugInROIs ( struct config_params *cp, struct pbook_page *page, 
						 struct GE_identifier *GEIDs, struct pixel_rectangle *ROIs, 
						 struct graphic_assembly_list *GA_list )
{
	int i, index;
	struct layout *L;
	struct viewport *VP;
	struct photo *ph;

	L = &( page->page_L );
	if ( L->num_VPs <= 0 ) {
		exitOrException("\nerror plugging in ROI's ... expect at least one viewport on page");
	}

	for ( i = 0; i < L->num_VPs; i++ ) {
		VP = &( L->VPs[i] );
		if ( typeOfGE ( &(VP->GE_ID), GA_list ) == PHOTO ) {
			ph = photoFromGEID ( &( VP->GE_ID ), GA_list );
			index = indexOfGAInListOfGEIDs ( VP->GE_ID.GA_index, GEIDs, L->num_VPs );

			ph->has_ROI = 0;
			ph->ROI = ROIs[index];
			if ( ROIIsProperSubsetOfPhoto ( cp, ph, &( ph->ROI ) ) ) {
				ph->has_ROI = 1;
			}
		}
	}
}

static void recordGEIDsFromLayout ( struct pbook_page *page, struct GE_identifier *GEIDs,
									struct graphic_assembly *selected_GA, 
									struct graphic_assembly_list *GA_list )
{
	int i, index, last_index;
	struct layout *L;
	struct viewport *VP;
	struct GE_identifier temp_GEID;

	L = &( page->page_L );
	for ( i = 0; i < L->num_VPs; i++ ) {
		VP = &( L->VPs[i] );
		GEIDs[i] = VP->GE_ID;
	}

	// make it so that the GEID associated with the selected GA is last
	last_index = L->num_VPs - 1;
	index = indexOfGAInListOfGEIDs ( selected_GA->GA_index, GEIDs, L->num_VPs );

	temp_GEID = GEIDs[index];
	GEIDs[index] = GEIDs[last_index];
	GEIDs[last_index] = temp_GEID;
}

static int determineProposedROIsToSetDimensions ( struct config_params *cp, struct pbook_page *page,
												  struct graphic_assembly *selected_GA, 
												  struct GE_identifier *GEIDs,
												  struct pixel_rectangle *proposed_ROIs,
												  double height, double width, 
												  struct graphic_assembly_list *GA_list )
{
	int i, index;
	double original_photo_height, original_photo_width;
	double target_photo_height, target_photo_width;
	double original_pbb_height, original_pbb_width;
	double target_pbb_height, target_pbb_width;
	double *target_heights, *target_widths;
	double delta_height, delta_width, target_aspect;
	struct GE_treeNode *GE_tree, *root;
	struct layout *L;
	struct photo *ph;
	struct fixed_dimensions_version *fd_ver;

	L = &( page->page_L );

	GE_tree = new struct GE_treeNode [ treeLen ( L->num_VPs ) ];
	subTToGE ( cp, GE_tree, page, L->num_VPs, GA_list );
	FAInitTermNodeBBs ( cp, GE_tree, L, GA_list );
	FAAccumBBs ( cp, GE_tree, L->num_VPs, GE_tree[0].value );
	root = &( GE_tree[0] );

	// get the dimensions of the original principal bounding box 
	original_pbb_height = sqrt ( root->bb_e * root->bb_a );
	original_pbb_width  = sqrt ( root->bb_e / root->bb_a );

	// verify that original bounding box does not extend outside the page
	if ( original_pbb_height > page->usable_height ) {
		if ( doublesDiffer ( original_pbb_height, page->usable_height ) ) {
			exitOrException("\ndid not expect input layout to exceed usable area");
		}
	}
	if ( original_pbb_width > page->usable_width ) {
		if ( doublesDiffer ( original_pbb_width, page->usable_width ) ) {
			exitOrException("\ndid not expect input layout to exceed usable area");
		}
	}

	// verity that at least one dimension of original bounding box equals usable area
	if ( ( doublesDiffer ( original_pbb_height, page->usable_height ) ) && 
		 ( doublesDiffer ( original_pbb_width, page->usable_width ) ) ) {
		exitOrException("\nlayout does not match usable area in at least one direction");
	}

	//
	// Part I.  set the target dimensions for the selected GA
	//

	// get current dimensions of the selected GA
	// and set target dimensions of the selected GA
	//
	// these dimensions account for the GA only, 
	// not including the border around it 
	original_photo_height = GAHeightFromLayout ( selected_GA, L );
	original_photo_width  = GAWidthFromLayout ( selected_GA, L );
	target_photo_height = height;
	target_photo_width = width;

	// if GA reaches across the useable area in one direction,
	// then its dimension in that direction must remain fixed
	if ( GAIsOnlyGAInPath ( selected_GA->GA_index, GE_tree, L->num_VPs, VERT, GA_list ) ) {
		if ( doublesDoNotDiffer ( original_pbb_height, page->usable_height ) ) {
			if ( doublesDiffer ( original_photo_height, target_photo_height ) ) {
				delete [] GE_tree;
				return FAIL;
			}
		}
	}
	if ( GAIsOnlyGAInPath ( selected_GA->GA_index, GE_tree, L->num_VPs, HORIZ, GA_list ) ) {
		if ( doublesDoNotDiffer ( original_pbb_width, page->usable_width ) ) {
			if ( doublesDiffer ( original_photo_width, target_photo_width ) ) {
				delete [] GE_tree;
				return FAIL;
			}
		}
	}

	target_heights = new double [ L->num_VPs ];
	target_widths = new double [ L->num_VPs ];
	for ( i = 0; i < L->num_VPs; i++ ) {
		target_heights[i] = -1.0;
		target_widths[i]  = -1.0;
	}

	index = indexOfGAInListOfGEIDs ( selected_GA->GA_index, GEIDs, L->num_VPs );
	target_heights[index] = target_photo_height;
	target_widths[index]  = target_photo_width;

	//
	// Part II.  determine target dimensions for any other photos
	//

	if ( L->num_VPs > 1 ) {
		// determine target dimensions of the principal bounding box
		//
		// these dimensions include borders around photos 
		// and spacing between adjacent photos
		delta_height = target_photo_height - original_photo_height;
		delta_width  = target_photo_width  - original_photo_width;

		target_pbb_height = original_pbb_height + delta_height;
		target_pbb_width = original_pbb_width + delta_width;

		if ( delta_height > 0.0 ) {
			if ( target_pbb_height > page->usable_height ) {
				target_pbb_height = page->usable_height;
			}
		}
		else {
			if ( doublesDoNotDiffer ( original_pbb_height, page->usable_height ) ) {
				target_pbb_height = page->usable_height;
			}
		}

		if ( delta_width > 0.0 ) {
			if ( target_pbb_width > page->usable_width ) {
				target_pbb_width = page->usable_width;
			}
		}
		else {
			if ( doublesDoNotDiffer ( original_pbb_width, page->usable_width ) ) {
				target_pbb_width = page->usable_width;
			}
		}

		// generate constraints and solve for target dimensions of the other photos
		if ( determineTargetDimensions ( cp, L, GE_tree, GEIDs, target_heights, 
										 target_widths, selected_GA, 
										 target_pbb_height, target_pbb_width, 
										 GA_list ) == FAIL ) {
			delete [] target_widths;
			delete [] target_heights;
			delete [] GE_tree;
			return FAIL;
		}
	}

	// Part III.  determine proposed ROIs from the target dimensions 
	for ( i = 0; i < L->num_VPs; i++ ) {
		if ( ( target_heights[i] < EPSILON ) || ( target_widths[i] < EPSILON ) ) {
			exitOrException("\ninvalid target dimension");
		}
		target_aspect = target_heights[i] / target_widths[i];

		if ( typeOfGE ( &(GEIDs[i]), GA_list ) == PHOTO ) {
			// get the photo from the layout listing
			ph = photoFromGEID ( &( GEIDs[i] ), GA_list );
			computeVisibleRectangle ( cp, &( proposed_ROIs[i] ), target_aspect, ph );
		}
		else {
			fd_ver = fixedDimensionsVersionFromGEID ( &(GEIDs[i]), GA_list );
			fd_ver->height = target_heights[i];
			fd_ver->width = target_widths[i];
		}
	}

	delete [] target_widths;
	delete [] target_heights;
	delete [] GE_tree;
	return PASS;
}

static void getPathsThroughGA ( struct config_params *cp, 
								struct pbook_page *page, int selected_GA_index,
								struct GE_treeNode *GE_tree, int node_value, 
								struct path *h_p, struct path *v_p, 
								struct graphic_assembly_list *GA_list )
{
	int num_GEs;
	struct GE_treeNode *node, *Lchild, *Rchild;
	struct path L_h_p, L_v_p, R_h_p, R_v_p;

	num_GEs = page->page_L.num_VPs;
	node = GETreeNode ( GE_tree, node_value, num_GEs );
	if ( node->value > 0 ) {
		startPathsThroughExistingLayout ( h_p, v_p, node, page, GA_list );
		return;
	}

	// process the children of this node 
	Lchild = GETreeLeftChild ( GE_tree, node, num_GEs );
	Rchild = GETreeRightChild ( GE_tree, node, num_GEs );
	getPathsThroughGA ( cp, page, selected_GA_index, GE_tree, Lchild->value, &L_h_p, &L_v_p, GA_list );
	getPathsThroughGA ( cp, page, selected_GA_index, GE_tree, Rchild->value, &R_h_p, &R_v_p, GA_list );

	// combine paths of the children to create paths of the current node,
	// taking care to retain any path that contains the selected GA
	if ( node->cut_dir == VERT ) {
		concatenatePaths ( cp, GE_tree, num_GEs, h_p, &L_h_p, &R_h_p, node );
		if ( GAIsInPath ( &R_v_p, selected_GA_index, GE_tree, num_GEs ) ) {
			copyPath ( v_p, &R_v_p );
		}
		else {
			copyPath ( v_p, &L_v_p );
		}
	}
	else {
		concatenatePaths ( cp, GE_tree, num_GEs, v_p, &L_v_p, &R_v_p, node );
		if ( GAIsInPath ( &R_h_p, selected_GA_index, GE_tree, num_GEs ) ) {
			copyPath ( h_p, &R_h_p );
		}
		else {
			copyPath ( h_p, &L_h_p );
		}
	}

	delete [] L_h_p.nodes;
	delete [] L_v_p.nodes;
	delete [] R_h_p.nodes;
	delete [] R_v_p.nodes;
}

static int GAIsInPath ( struct path *p, int GA_index, 
						struct GE_treeNode *GE_tree, int num_GEs )
{
	int i, node_value;
	struct GE_treeNode *node;
	struct GE_identifier *GE_ID;

	for ( i = 0; i < p->num_steps; i++ ) {
		node_value = p->nodes[i];

		if ( node_value > 0 ) {
			node = GETreeNode ( GE_tree, node_value, num_GEs );
			GE_ID = &( node->GE_ID );

			if ( GA_index == GE_ID->GA_index ) {
				return ( 1 );
			}
		}
	}

	return ( 0 );
}

static void startPathsThroughExistingLayout ( struct path *h_p, struct path *v_p, 
											  struct GE_treeNode *node,
											  struct pbook_page *page,
											  struct graphic_assembly_list *GA_list )
{
	int GA_index;
	struct graphic_assembly *GA;

	GA_index = node->GE_ID.GA_index;
	GA = &( GA_list->GA[GA_index] );

	h_p->dir = HORIZ;
	h_p->num_steps = 1;
	h_p->nodes = new int [ 1 ];
	h_p->nodes[0] = node->value;
	h_p->var_dist_term = 0.0;
	h_p->fixed_dist = GAWidthFromLayout ( GA, &( page->page_L ) );

	v_p->dir = VERT;
	v_p->num_steps = 1;
	v_p->nodes = new int [ 1 ];
	v_p->nodes[0] = node->value;
	v_p->var_dist_term = 0.0;
	v_p->fixed_dist = GAHeightFromLayout ( GA, &( page->page_L ) );

	// add border to the fixed distances
	h_p->fixed_dist += ( 2.0 * node->border );
	v_p->fixed_dist += ( 2.0 * node->border );
}

static int GAIsOnlyGAInPath ( int selected_GA, struct GE_treeNode *GE_tree, 
								 int num_GEs, int path_dir,
								 struct graphic_assembly_list *GA_list )
{
	struct GE_treeNode *node, *parent;

	if ( num_GEs < 1 ) {
		exitOrException("\nerror determining if only one GA in a path; expect at least one GE");
	}

	node = GETreeNodeFromGAIndex ( GE_tree, num_GEs, selected_GA, GA_list );
	while ( node->value != node->parent ) {
		parent = GETreeParent ( GE_tree, node, num_GEs );
		if ( parent->cut_dir != path_dir ) {
			return ( 0 );
		}

		node = parent;
	}

	return ( 1 );
}

static int determineTargetDimensions ( struct config_params *cp, struct layout *L, 
									   struct GE_treeNode *GE_tree, 
									   struct GE_identifier *GEIDs,
									   double *target_heights, double *target_widths,
									   struct graphic_assembly *selected_GA,
									   double target_pbb_height, double target_pbb_width,
									   struct graphic_assembly_list *GA_list )
{
	int i, num_GEs, row_count, fixed_step_temp_flag, fixed_step_perm_flag; 
	double **a_ht, *b_ht, *ht_solution;
	double **a_wd, *b_wd, *wd_solution;
	struct path h_p, v_p;

	num_GEs = L->num_VPs;
	if ( num_GEs <= 1 ) {
		exitOrException("\ninvalid number of GE's when trying to determine target dimensions");
	}

	allocateMatrices ( &a_ht, &b_ht, num_GEs - 1 );
	row_count = fixed_step_temp_flag = fixed_step_perm_flag = 0;
	populateDistanceTableau ( cp, L, GE_tree, GA_list, GE_tree[0].value, VERT, &v_p, 
							  a_ht, b_ht, &row_count, selected_GA, 
							  target_heights[num_GEs-1], target_pbb_height, 
							  &fixed_step_temp_flag, &fixed_step_perm_flag, GEIDs );
	if ( row_count != num_GEs - 1 ) {exitOrException("\nerror populating matrices for one-D constraints");}
	ht_solution = new double [ num_GEs - 1 ];
	computeSolutionVector ( a_ht, b_ht, ht_solution, num_GEs - 1 );
	for ( i = 0; i < num_GEs - 1; i++ ) { target_heights[i] = ht_solution[i]; }
	if ( testDistancesSolution ( GE_tree, target_heights, &v_p, GEIDs, num_GEs, target_pbb_height ) == FAIL ) {
		delete [] ht_solution;
		delete [] v_p.nodes;
		deleteMatrices ( a_ht, b_ht, num_GEs - 1 );

		return FAIL;
	}

	allocateMatrices ( &a_wd, &b_wd, num_GEs - 1 );
	row_count = fixed_step_temp_flag = fixed_step_perm_flag = 0;
	populateDistanceTableau ( cp, L, GE_tree, GA_list, GE_tree[0].value, HORIZ, &h_p, 
							  a_wd, b_wd, &row_count, selected_GA, 
							  target_widths[num_GEs-1], target_pbb_width, 
							  &fixed_step_temp_flag, &fixed_step_perm_flag, GEIDs );
	if ( row_count != num_GEs - 1 ) {exitOrException("\nerror populating matrices for one-D constraints");}
	wd_solution = new double [ num_GEs - 1 ];
	computeSolutionVector ( a_wd, b_wd, wd_solution, num_GEs - 1 );
	for ( i = 0; i < num_GEs - 1; i++ ) { target_widths[i] = wd_solution[i]; }
	if ( testDistancesSolution ( GE_tree, target_widths, &h_p, GEIDs, num_GEs, target_pbb_width ) == FAIL ) {
		delete [] wd_solution;
		delete [] h_p.nodes;
		deleteMatrices ( a_wd, b_wd, num_GEs - 1 );
		delete [] ht_solution;
		delete [] v_p.nodes;
		deleteMatrices ( a_ht, b_ht, num_GEs - 1 );

		return FAIL;
	}

//printf("target ga height = %lf\n",target_heights[num_GEs - 1]);
//printf("target ga width = %lf\n",target_widths[num_GEs - 1]);
//printf("target pbb height = %lf\n",target_pbb_height);
//printf("target pbb width = %lf\n",target_pbb_width);
//printGETree ( GE_tree, L->num_VPs );
//printGEIDs ( GEIDs, GA_list, L, num_GEs );
//printf("*** height system:\n");
//printMatrixAndVector ( a_ht, b_ht, num_GEs - 1 );
//printf("*** width system:\n");
//printMatrixAndVector ( a_wd, b_wd, num_GEs - 1 );

	delete [] wd_solution;
	delete [] h_p.nodes;
	deleteMatrices ( a_wd, b_wd, num_GEs - 1 );
	delete [] ht_solution;
	delete [] v_p.nodes;
	deleteMatrices ( a_ht, b_ht, num_GEs - 1 );

	return PASS;
}

static void printGEIDs ( struct GE_identifier *GEIDs, 
						 struct graphic_assembly_list *GA_list,
						 struct layout *L, int num_GEs )
{
	int i;

	for ( i = 0; i < num_GEs; i++ ) {
		if ( typeOfGE ( &(GEIDs[i]), GA_list ) == PHOTO ) {
			printf("GEID: %d.%d --- %s --- wd %3.3lf, ht %3.3lf\n",
				GEIDs[i].GA_index,GEIDs[i].GE_index,
				photoFromGEID(&(GEIDs[i]),GA_list)->filename,
				GAWidthFromLayout(&(GA_list->GA[GEIDs[i].GA_index]),L),
				GAHeightFromLayout(&(GA_list->GA[GEIDs[i].GA_index]),L));
		}
		else {
			printf("GEID: %d.%d --- wd %3.3lf, ht %3.3lf\n",
				GEIDs[i].GA_index,GEIDs[i].GE_index,
				GAWidthFromLayout(&(GA_list->GA[GEIDs[i].GA_index]),L),
				GAHeightFromLayout(&(GA_list->GA[GEIDs[i].GA_index]),L));
		}
	}
}

static void printMatrixAndVector ( double **a, double *b, int dimension )
{
	int i, j;
	double *a_row, *b_row;

	for ( i = 0; i < dimension; i++ ) {
		a_row =    a[i];
		b_row = &( b[i] );

		printf("\t");
		for ( j = 0; j < dimension; j++ ) {
			printf("%3.3lf  ",a_row[j]);
		}
		printf("%3.3lf",b_row[0]);
		printf("\n");
	}
}

static void populateDistanceTableau ( struct config_params *cp, struct layout *L, 
									  struct GE_treeNode *GE_tree, 
									  struct graphic_assembly_list *GA_list,
									  int node_value, int path_dir, struct path *p, 
									  double **a, double *b, int *row_count, 
									  struct graphic_assembly *selected_GA, 
									  double selected_GA_dimension, double pbb_dimension,
									  int *fixed_step_temp_flag, int *fixed_step_perm_flag,
									  struct GE_identifier *GEIDs )
{
	int num_GEs, add_constraint_flag;
	int L_fixed_step_temp_flag, L_fixed_step_perm_flag;
	int R_fixed_step_temp_flag, R_fixed_step_perm_flag;
	struct GE_treeNode *node, *Lchild, *Rchild;
	struct path L_p, R_p;
	double *a_row, *b_row;

	num_GEs = L->num_VPs;
	node = GETreeNode ( GE_tree, node_value, num_GEs );
	if ( node->value > 0 ) {
		startPathForDistanceTableau ( path_dir, p, node, L, selected_GA, 
									  selected_GA_dimension, fixed_step_temp_flag, 
									  fixed_step_perm_flag, GA_list );
		return;
	}

	// process the children of the current node
	Lchild = GETreeLeftChild ( GE_tree, node, num_GEs );
	Rchild = GETreeRightChild ( GE_tree, node, num_GEs );
	populateDistanceTableau ( cp, L, GE_tree, GA_list, Lchild->value, path_dir, 
							  &L_p, a, b, row_count, selected_GA, 
							  selected_GA_dimension, pbb_dimension,
							  &L_fixed_step_temp_flag, &L_fixed_step_perm_flag, 
							  GEIDs );
	populateDistanceTableau ( cp, L, GE_tree, GA_list, Rchild->value, path_dir, 
							  &R_p, a, b, row_count, selected_GA, 
							  selected_GA_dimension, pbb_dimension, 
							  &R_fixed_step_temp_flag, &R_fixed_step_perm_flag, 
							  GEIDs );

	// process the current node

	// decide whether to make a constraint from this node
	add_constraint_flag = 1;
	if ( ( L_fixed_step_temp_flag == 1 ) || ( R_fixed_step_temp_flag == 1 ) ) {
		if ( path_dir != node->cut_dir ) {
			add_constraint_flag = 0;
		}
	}

	if ( add_constraint_flag == 1 ) {
		if ( *row_count >= num_GEs - 1 ) {
			exitOrException("\nerror populating matrices for one-D constraints");
		}
		a_row =    a[(*row_count)]  ;
		b_row = &( b[(*row_count)] );

		// add the constraint
		putPathIntoDistanceTableauRow ( GE_tree, num_GEs, L, GEIDs, GA_list, &L_p, &R_p, 
										selected_GA, a_row, b_row, node->cut_dir );

		// increment counter so next constraint will be written in a different row
		(*row_count)++;
	}

	// set the temporary fixed-step flag for the current node
	*fixed_step_temp_flag = 0;
	if ( ( L_fixed_step_temp_flag == 1 ) || ( R_fixed_step_temp_flag == 1 ) ) {
		if ( path_dir == node->cut_dir ) {
			*fixed_step_temp_flag = 1;
		}
	}

	// set the permanent fixed-step flag for the current node
	*fixed_step_perm_flag = 0;
	if ( ( L_fixed_step_perm_flag == 1 ) || ( R_fixed_step_perm_flag == 1 ) ) {
		*fixed_step_perm_flag = 1;
	}

	// create a path for the current node to pass up to the calling routine
	if ( path_dir == node->cut_dir ) {
		if ( R_fixed_step_perm_flag == 1 ) {
			copyPath ( p, &R_p );
		}
		else {
			copyPath ( p, &L_p );
		}
	}
	else {
		concatenatePaths ( cp, GE_tree, num_GEs, p, &L_p, &R_p, node );
	}

	// if this node is the root, add one more constraint if necessary
	if ( node->value == node->parent ) {
		if ( *row_count == num_GEs - 2 ) {
			a_row =    a[(*row_count)]  ;
			b_row = &( b[(*row_count)] );

			// add the constraint
			finishDistanceTableau ( GE_tree, num_GEs, GEIDs, p, selected_GA, a_row, b_row, 
									pbb_dimension );

			(*row_count)++;
		}
	}

	delete [] L_p.nodes;
	delete [] R_p.nodes;
}

static void finishDistanceTableau ( struct GE_treeNode *GE_tree, int num_GEs, 
									struct GE_identifier *GEIDs, struct path *p,
									struct graphic_assembly *selected_GA, 
									double *a_row, double *b_row, 
									double pbb_dimension )
{
	int i, GA_index, col_index; 
	double coefficient;
	struct GE_treeNode *node;

	for ( i = 0; i < p->num_steps; i++ ) {
		if ( p->nodes[i] > 0 ) {
			node = GETreeNode ( GE_tree, p->nodes[i], num_GEs );
			GA_index = node->GE_ID.GA_index;

			if ( GA_index != selected_GA->GA_index ) {
				coefficient = 1.0;
				col_index = indexOfGAInListOfGEIDs ( GA_index, GEIDs, num_GEs );
				a_row[col_index] = coefficient;
			}
		}
	}

	*b_row = pbb_dimension - ( p->fixed_dist );
}

static void putPathIntoDistanceTableauRow ( struct GE_treeNode *GE_tree, int num_GEs, 
											struct layout *L, struct GE_identifier *GEIDs,
											struct graphic_assembly_list *GA_list,
											struct path *L_p, struct path *R_p,
											struct graphic_assembly *selected_GA, 
											double *a_row, double *b_row, int cut_dir )
{
	int i, path_dir, GA_index, col_index; 
	double coefficient;
	struct GE_treeNode *node;

	checkDirection ( L_p->dir );
	if ( L_p->dir != R_p->dir ) {
		exitOrException("\nerror putting path into distance tableau row");
	}
	path_dir = L_p->dir;

	for ( i = 0; i < L_p->num_steps; i++ ) {
		if ( L_p->nodes[i] > 0 ) {
			node = GETreeNode ( GE_tree, L_p->nodes[i], num_GEs );
			GA_index = node->GE_ID.GA_index;

			if ( GA_index != selected_GA->GA_index ) {
				if ( cut_dir == path_dir ) {
					coefficient = 1.0;
				}
				else {
					coefficient = 1.0 / ( L_p->var_dist_term );
				}
				col_index = indexOfGAInListOfGEIDs ( GA_index, GEIDs, num_GEs );
				a_row[col_index] = coefficient;
			}
		}
	}

	for ( i = 0; i < R_p->num_steps; i++ ) {
		if ( R_p->nodes[i] > 0 ) {
			node = GETreeNode ( GE_tree, R_p->nodes[i], num_GEs );
			GA_index = node->GE_ID.GA_index;

			if ( GA_index != selected_GA->GA_index ) {
				if ( cut_dir == path_dir ) {
					coefficient = -1.0;
				}
				else {
					coefficient = 0.0 - ( 1.0 / ( R_p->var_dist_term ) );
				}
				col_index = indexOfGAInListOfGEIDs ( GA_index, GEIDs, num_GEs );
				a_row[col_index] = coefficient;
			}
		}
	}

	if ( cut_dir == path_dir ) {
		*b_row = ( R_p->fixed_dist - L_p->fixed_dist );
	}
}

static void checkDirection ( int dir )
{
	if ( ( dir != VERT ) && ( dir != HORIZ ) ) {
		exitOrException("\ninvalid direction");
	}
}

static void startPathForDistanceTableau ( int path_dir, struct path *p, struct GE_treeNode *node,
										  struct layout *L, struct graphic_assembly *selected_GA, 
										  double selected_GA_dimension, 
										  int *fixed_step_temp_flag, int *fixed_step_perm_flag,
										  struct graphic_assembly_list *GA_list )
{
	int GA_index;
	struct graphic_assembly *GA;

	if ( ( path_dir != VERT ) && ( path_dir != HORIZ ) ) {
		exitOrException("\nerror starting path from layout: invalid direction");
	}

	GA_index = node->GE_ID.GA_index;
	GA = &( GA_list->GA[GA_index] );

	p->dir = path_dir;
	p->num_steps = 1;
	p->nodes = new int [ 1 ];
	p->nodes[0] = node->value;
	p->var_dist_term = p->fixed_dist = 0.0;
	if ( GA_index == selected_GA->GA_index ) {
		p->fixed_dist += selected_GA_dimension;
	}
	else {
		if ( path_dir == VERT ) {
			p->var_dist_term += GAHeightFromLayout ( GA, L );
		}
		else {
			p->var_dist_term += GAWidthFromLayout ( GA, L );
		}
	}
	p->fixed_dist += ( 2.0 * node->border );

	// if appropriate, set flags indicating that node has no variable component
	*fixed_step_temp_flag = *fixed_step_perm_flag = 0;
	if ( GA_index == selected_GA->GA_index ) {
		*fixed_step_temp_flag = *fixed_step_perm_flag = 1;
	}
}

static int indexOfGAInListOfGEIDs ( int GA_index, struct GE_identifier *GEIDs, 
									int num_GEs )
{
	int i, index, count;

	index = -1;
	count = 0;
	for ( i = 0; i < num_GEs; i++ ) {
		if ( GA_index == GEIDs[i].GA_index ) {
			index = i;
			count++;
		}
	}

	if ( count != 1 ) {
		exitOrException("\nerror trying to find index of GA in list of GEIDs");
	}
	if ( ( index < 0 ) || ( index >= num_GEs ) ) {
		exitOrException("\nerror trying to find index of GA in list of GEIDs");
	}

	return ( index );
}

static int tryToSetDimensions ( struct config_params *cp, struct pbook_page *page, 
								struct graphic_assembly *GA, double height, double width,
								struct graphic_assembly_list *GA_list )
{
	struct layout *L;
	struct GE_identifier *GEIDs;
	struct pixel_rectangle *proposed_ROIs;

	L = &( page->page_L );
	if ( L->num_VPs <= 0 ) {
		exitOrException("\nerror trying to set dimensions ... expect at least one viewport on page");
	}

	// scratch space
	GEIDs = new struct GE_identifier [ L->num_VPs ];
	proposed_ROIs = new struct pixel_rectangle [ L->num_VPs ];

	// write down the GEID's, with the GEID corresponding to the selected GA last
	recordGEIDsFromLayout ( page, GEIDs, GA, GA_list );

	// determine a set of proposed ROIs 
	if ( determineProposedROIsToSetDimensions ( cp, page, GA, GEIDs, proposed_ROIs, 
												height, width, GA_list ) != PASS ) {
		delete [] proposed_ROIs;
		delete [] GEIDs;
		return FAIL;
	}

	// plug in the proposed ROIs
	plugInROIs ( cp, page, GEIDs, proposed_ROIs, GA_list );
	delete [] proposed_ROIs;
	delete [] GEIDs;

	return ( reflowPage ( cp, page, false, GA_list ) );
}

int swapGAs ( struct config_params *cp, struct pbook_page *page, 
			  int GA_index_1, int GA_index_2,
			  struct graphic_assembly_list *GA_list )
{
	double area1, area2;
	struct graphic_assembly *GA1, *GA2;
	struct subT_treeNode *node1, *node2;

	GA1 = & ( GA_list->GA[GA_index_1] );
	GA2 = & ( GA_list->GA[GA_index_2] );

	// some error checks
	if ( page->num_GAs < 2 ) {
		exitOrException("\nunable to swap GA's");
	}
	if ( ( GA1->num_subTs <= 0 ) || ( GA2->num_subTs <= 0 ) ) {
		exitOrException("\nunable to swap GA's");
	}
	if ( !GAIsOnPage ( page, GA_index_1 ) ) {
		exitOrException("\nunable to swap GA's since one of the GA's is not on the page");
	}
	if ( !GAIsOnPage ( page, GA_index_2 ) ) {
		exitOrException("\nunable to swap GA's since one of the GA's is not on the page");
	}

	node1 = subTTreeNodeFromGAIndex ( page, GA1->GA_index );
	node2 = subTTreeNodeFromGAIndex ( page, GA2->GA_index );
	swapGAsInTree ( cp, page, node1, node2 );

	// plug photo areas into page schedule as the photos' relative areas;
	// compute target areas in case we need to select GA subtree indices during reflow
	area1 = GAAreaFromLayout ( GA1, &( page->page_L ) );
	area2 = GAAreaFromLayout ( GA2, &( page->page_L ) );
	setPhotoRelativeAreasFromLayout ( page, GA_list );
	if ( typeOfGA ( GA1 ) == PHOTO ) recordAreasFromThinAir ( &(page->sched), GA1->GA_index, GA_list, area2 );
	if ( typeOfGA ( GA2 ) == PHOTO ) recordAreasFromThinAir ( &(page->sched), GA2->GA_index, GA_list, area1 );
	computeTargetAreas ( cp, &(page->sched), GA_list );

	if ( reflowPage ( cp, page, true, GA_list ) != PASS ) {
		exitOrException("\nerror implementing swap");
		return FAIL;
	}

	return PASS;
}

static void deduceMarginsFromLayout ( struct config_params *cp, struct layout *L )
{
	int i;
	double top_extent, bottom_extent, right_extent, left_extent;
	struct viewport *VP;
	struct physical_rectangle *p_rect;

	top_extent = -1.0;
	bottom_extent = maxExtentInLayout ( L ) + 1.0;
	right_extent = -1.0;
	left_extent = maxExtentInLayout ( L ) + 1.0;

	// start with the convex hull around the physical rectangles in L
	for ( i = 0; i < L->num_VPs; i++ ) {
		VP = &( L->VPs[i] );
		p_rect = &( VP->p_rect );

		if ( top_extent < p_rect->vert_offset + p_rect->height ) {
			top_extent = p_rect->vert_offset + p_rect->height;
		}
		if ( bottom_extent > p_rect->vert_offset ) {
			bottom_extent = p_rect->vert_offset;
		}
		if ( right_extent < p_rect->horiz_offset + p_rect->width ) {
			right_extent = p_rect->horiz_offset + p_rect->width ;
		}
		if ( left_extent > p_rect->horiz_offset ) {
			left_extent = p_rect->horiz_offset;
		}
	}

	// back out the borders around the photos
	top_extent += cp->BORDER;
	bottom_extent -= cp->BORDER;
	right_extent += cp->BORDER;
	left_extent -= cp->BORDER;

	cp->topMargin = cp->pageHeight - top_extent;
	cp->bottomMargin = bottom_extent;
	cp->rightMargin = cp->pageWidth - right_extent;
	cp->leftMargin = left_extent;

	if ( ( cp->bottomMargin < 0.0 - EPSILON ) || 
		 ( cp->leftMargin < 0.0 - EPSILON )   || 
		 ( cp->topMargin < 0.0 - EPSILON )    || 
		 ( cp->rightMargin < 0.0 - EPSILON	  ) ) {
		exitOrException("\nerror deducing margins from layout");
	}
}

static double maxExtentInLayout ( struct layout *L )
{
	int i;
	double max;
	struct viewport *VP;
	struct physical_rectangle *p_rect;

	max = -1.0;
	for ( i = 0; i < L->num_VPs; i++ ) {
		VP = &( L->VPs[i] );
		p_rect = &( VP->p_rect );

		if ( max < p_rect->vert_offset + p_rect->height ) {
			max = p_rect->vert_offset + p_rect->height;
		}

		if ( max < p_rect->horiz_offset + p_rect->width ) {
			max = p_rect->horiz_offset + p_rect->width;
		}
	}

	if ( max < EPSILON ) {
		exitOrException("\nerror finding maximum extent in layout");
	}
	return max;
}

static void swapGAsInTree ( struct config_params *cp, struct pbook_page *page,
							struct subT_treeNode *GA_node_1, 
							struct subT_treeNode *GA_node_2 )
{
	struct subT_treeNode *parent_node, *parent_node_1, *parent_node_2;

	if ( GA_node_1->parent == GA_node_2->parent ) {
		// these GA's are siblings in the tree structure,
		// so there is no need to swap the their "parent" values;
		// only need to swap the values of Rchild and Lchild 
		// according to their parent
		parent_node = subTTreeNodeFromTreeValue ( page, GA_node_1->parent );

		if ( ( parent_node->Rchild == GA_node_1->value ) && 
			 ( parent_node->Lchild == GA_node_2->value ) ) {
			parent_node->Rchild = GA_node_2->value;
			parent_node->Lchild = GA_node_1->value;
		}
		else if ( ( parent_node->Rchild == GA_node_2->value ) && 
				  ( parent_node->Lchild == GA_node_1->value ) ) {
			parent_node->Rchild = GA_node_1->value;
			parent_node->Lchild = GA_node_2->value;
		}
		else {exitOrException("\nerror swapping GA's in tree structure");}
	}
	else {
		// these GA's are not siblings in the tree structure,
		// so swap the parent values pointed to from the terminal nodes
		// and swap the Rchild/Lchild values pointed to from the interior nodes
		parent_node_1 = subTTreeNodeFromTreeValue ( page, GA_node_1->parent );
		parent_node_2 = subTTreeNodeFromTreeValue ( page, GA_node_2->parent );

		GA_node_1->parent = parent_node_2->value;
		GA_node_2->parent = parent_node_1->value;

		if ( parent_node_1->Rchild == GA_node_1->value ) {
			parent_node_1->Rchild = GA_node_2->value;
		}
		else if ( parent_node_1->Lchild == GA_node_1->value ) {
			parent_node_1->Lchild = GA_node_2->value;
		}
		else {exitOrException("\nerror swapping GA's in tree structure");}

		if ( parent_node_2->Rchild == GA_node_2->value ) {
			parent_node_2->Rchild = GA_node_1->value;
		}
		else if ( parent_node_2->Lchild == GA_node_2->value ) {
			parent_node_2->Lchild = GA_node_1->value;
		}
		else {exitOrException("\nerror swapping GA's in tree structure");}
	}
}

static int addGAToPage ( struct config_params *cp, struct pbook_page *page,
						   struct graphic_assembly *GA, 
						   int subT_index, int node_index, int cut_dir, 
						   struct graphic_assembly_list *GA_list )
{
	struct subT_identifier subT_ID;
	struct subT_treeNode *new_page_T;

	if ( GAIsOnPage ( page, GA->GA_index ) ) {
		exitOrException("\ncan not add a GA to a page when the GA is already on the page");
	}

	// add the new subT identifier to the page tree
	subT_ID.GA_index = GA->GA_index;
	subT_ID.subT_index = subT_index;
	// allocate a new tree that accomodates the new GA
	new_page_T = new struct subT_treeNode [ treeLen ( page->num_GAs + 1 ) ];
	if ( page->num_GAs == 0 ) {
		subTInitTree ( new_page_T, &subT_ID );
	}
	else {
		// notice in the following copy we will not use all the memory just allocated
		subTCopyTree ( page->page_T, new_page_T, page->num_GAs );
		delete [] page->page_T;
		subTAddLeafToTree ( new_page_T, &subT_ID, new_page_T, page->num_GAs, node_index, cut_dir );
	}
	page->page_T = new_page_T;

	// update the layout lists and increment the number of GAs on the page
	addGARealizationToLayout ( &( page->page_L ), GA, &subT_ID );
	(page->num_GAs)++;

	return computeObjAreas ( cp, page, GA_list );
}


static void removeGAFromLayout ( struct layout *L, struct graphic_assembly *GA )
{
	int new_num_GEs, count, i;
	struct GE_identifier *GE_ID;

	if ( ( L->num_VPs <= 0 ) || ( numVisibleGEs ( GA ) <= 0 ) ) {
		exitOrException("\nerror removing GA from a layout");
	}

	new_num_GEs = L->num_VPs - numVisibleGEs ( GA );

	if ( new_num_GEs < 0 ) {
		exitOrException("\nerror removing GA from a layout");
	}

	if ( new_num_GEs == 0 ) {
		clearLayout ( L );
		return;
	}

	count = 0;
	for ( i = 0; i < L->num_VPs; i++ ) {
		GE_ID = &( L->VPs[i].GE_ID );
		if ( GE_ID->GA_index != GA->GA_index ) {
			if ( count < L->num_VPs ) {
				L->VPs[count].GE_ID = *GE_ID;
				count++;
			}
			else {
				exitOrException("\nerror removing GA from a layout");
			}
		}
	}
	if ( count != new_num_GEs ) {
		exitOrException("\nerror removing GA from a layout");
	}

	L->num_VPs = new_num_GEs;
}

static int placeGAOnPage ( struct config_params *cp, struct pbook_page *page, 
							 int GA_index, struct graphic_assembly_list *GA_list, 
							 int *subT_index, int *node_index, int *cut_dir )
{
	struct graphic_assembly *GA;
	struct pbook_page scratch_page;
	struct subT_treeNode *scratch_T, *best_T;
	struct layout best_L;
	struct subT_identifier subT_ID;
	int k, i;

	GA = & ( GA_list->GA[GA_index] );

	if ( ( page->num_GAs < 0 ) || ( GA->num_subTs <= 0 ) ) {
		exitOrException("\nunable to place GA on page");
	}
	if ( GAIsOnPage ( page, GA_index ) ) {
		exitOrException("\nunable to place GA on page since GA is already on page");
	}

	// make a copy of the input page where we can test candidates
	duplicatePage ( page, &scratch_page );
	// replace tree on scratch page with bigger tree, to accomodate new GA
	scratch_T = new struct subT_treeNode [ treeLen ( page->num_GAs + 1 ) ];
	// notice on the next line, we're only filling up part of scratch_T
	subTCopyTree ( page->page_T, scratch_T, page->num_GAs );
	// replace the pointer in the scratch page
	if ( page->num_GAs > 0 ) {
		delete [] scratch_page.page_T;
	}
	scratch_page.page_T = scratch_T;
	(scratch_page.num_GAs)++;

	// allocate buffers to store the best tree and layout yet 
	// as we go through the trials
	best_T = new struct subT_treeNode [ treeLen ( scratch_page.num_GAs ) ];
	best_L.VPs = new struct viewport [ scratch_page.page_L.num_VPs + numVisibleGEs ( GA ) ];

	*node_index = -1;
	clearScore ();
	for ( k = 0; k < GA->num_subTs; k++ ) {
		subT_ID.GA_index = GA->GA_index;
		subT_ID.subT_index = k;

		// add this GA realization to the layout listing on the scratch page
		addGARealizationToLayout ( &(scratch_page.page_L), GA, &subT_ID );

		if ( page->num_GAs == 0 ) {
			subTInitTree ( scratch_page.page_T, &subT_ID );
			if ( computeObjAreas ( cp, &scratch_page, GA_list ) == PASS ) {
				if ( updateScore ( &scratch_page, best_T, &best_L, GA_list ) ) {
					*subT_index = subT_ID.subT_index;
					*node_index = 0;
					*cut_dir = HORIZ; // THIS IS NOT USED - JUST PLUGGING IN A FEASIBLE VALUE
				}
			}
		}
		else {
			for ( i = 0; i < treeLen ( page->num_GAs ); i++ ) {
				subTAddLeafToTree ( page->page_T, &subT_ID, scratch_page.page_T, page->num_GAs, i, HORIZ );
				if ( computeObjAreas ( cp, &scratch_page, GA_list ) == PASS ) {
					if ( updateScore ( &scratch_page, best_T, &best_L, GA_list ) ) {
						*subT_index = subT_ID.subT_index;
						*node_index = i;
						*cut_dir = HORIZ;
					}
				}

				subTAddLeafToTree ( page->page_T, &subT_ID, scratch_page.page_T, page->num_GAs, i, VERT );
				if ( computeObjAreas ( cp, &scratch_page, GA_list ) == PASS ) {
					if ( updateScore ( &scratch_page, best_T, &best_L, GA_list ) ) {
						*subT_index = subT_ID.subT_index;
						*node_index = i;
						*cut_dir = VERT;
					}
				}

			}
		}

		// remove this GA realization from layout listing on scratch page
		removeGAFromLayout ( &(scratch_page.page_L), GA );
	}

	if ( *node_index < 0 ) {
		// could not place GA on page - return without having changed the page
		delete [] best_L.VPs;
		delete [] best_T;
		clearPage ( cp, &scratch_page );
		return FAIL;
	}

	// a feasible layout was found; delete any arrays being used 
	// by the input page; copy the best tree and layout back into scratch page
	// and copy the scratch page into the input page 
	// (using a structure copy - i.e. by copying pointers to the dynamic arrays)
	clearPage ( cp, page );
	subTCopyTree ( best_T, scratch_page.page_T, scratch_page.num_GAs );
	copyLayout ( &best_L, &(scratch_page.page_L) );
	*page = scratch_page;

	delete [] best_L.VPs;
	delete [] best_T;

	return PASS;
}


static int GAIsOnPage ( struct pbook_page *page, int GA_index )
{
	int i;
	struct subT_identifier *subT_ID;

	for ( i = 0; i < page->num_GAs; i++ ) {
		subT_ID = subTIDFromTreeValue ( page->page_T, page->num_GAs, i+1 );

		if ( subT_ID->GA_index == GA_index ) {
			return 1;
		}
	}

	return 0;
}


static void evaluatePotentialMove ( struct config_params *cp, struct potential_move *pmv, 
									struct pbook_page *page, int GA_index, 
									struct graphic_assembly_list *GA_list )
{
	struct pbook_page scratch_page;

	// determine allowability of move
	determineMoveAllowability ( &( pmv->is_allowed ), page );
	if ( !( pmv->is_allowed ) ) return;

	// there are at least two graphic assemblies on the page

	// copy the source page into a "scratch" page
	duplicatePage ( page,  &scratch_page );

	// remove the source GA
	if ( removeGAFromPage ( cp, &scratch_page, GA_index, GA_list ) == FAIL ) {
		pmv->is_allowed = 0;
		clearPage ( cp, &scratch_page );
		return;
	}

	// put the GA in the best place on the scratch page,
	// and record the subT_index, node and cut direction 
	if ( placeGAOnPage ( cp, &scratch_page, GA_index, GA_list, &(pmv->subT_index),
						   &(pmv->node_index), &(pmv->cut_dir) ) == FAIL ) {
		pmv->is_allowed = 0;
		clearPage ( cp, &scratch_page );
		return;
	}

	// record the change in score.  this will be interpreted by ( new - old ), 
	// so a positive score change indicates a desirable modification 
	pmv->score_change = scratch_page.page_L.score - page->page_L.score;

	clearPage ( cp, &scratch_page );
}

static void duplicatePage ( struct pbook_page *from_page, struct pbook_page *to_page )
{
	if ( from_page->num_GAs < 0 ) {
		exitOrException("\nunable to copy page: invalid number of GAs");
	}

	if ( from_page->num_GAs == 0 ) {
		to_page->page_T = NULL;
	}
	else {
		to_page->page_T = new struct subT_treeNode [ treeLen ( from_page->num_GAs ) ];
	}

	if ( from_page->page_L.num_VPs == 0 ) {
		to_page->page_L.VPs = NULL;
	}
	else {
		to_page->page_L.VPs = new struct viewport [ from_page->page_L.num_VPs ];
	}

	if ( from_page->sched.num_GAs == 0 ) {
		to_page->sched.pse = NULL;
	}
	else {
		initPageSchedule ( &( to_page->sched ), from_page->sched.num_GAs );
	}

	copyPage ( from_page, to_page );
}

static void duplicatePagesInPageList ( struct page_list *from_pg_list,
									   struct page_list *to_pg_list )
{
	int i;

	// routine assumes the pages array is allocated
	for ( i = 0; i < from_pg_list->num_pages; i++ ) {
		duplicatePage ( &( from_pg_list->pages[i] ), &( to_pg_list->pages[i] ) );
	}

	to_pg_list->num_pages = from_pg_list->num_pages;
}

static void copyPage ( struct pbook_page *from_page, struct pbook_page *to_page )
{
	to_page->num_GAs  = from_page->num_GAs;
	subTCopyTree ( from_page->page_T, to_page->page_T, from_page->num_GAs );
	copyLayout ( &(from_page->page_L), &(to_page->page_L) );
	to_page->usable_height	   = from_page->usable_height;
	to_page->usable_width	   = from_page->usable_width;
	copyPageSchedule ( &( from_page->sched ), &( to_page->sched ) );
}

static void copyLayout ( struct layout *from_L, struct layout *to_L )
{
	int i;

	// this routine assumes that if to_L already has an array allocated, 
	// then the array is sufficiently great in number of elements

	if ( to_L->VPs == NULL ) {
		if ( from_L->num_VPs > 0 ) {
			to_L->VPs = new struct viewport [ from_L->num_VPs ];
		}
	}

	to_L->num_VPs = from_L->num_VPs;
	for ( i = 0; i < from_L->num_VPs; i++ ) {
		to_L->VPs[i] = from_L->VPs[i];
	}
	to_L->score = from_L->score;
}


static void determineMoveAllowability ( int *is_allowed, struct pbook_page *src_page )
{
	*is_allowed = 1;

	// src_page->num_imgs should be at least 2;
	// if num_imgs were 1, then there would be nowhere to move 
	if ( src_page->num_GAs <= 1 ) *is_allowed = 0;
}


static void optimizeLayout ( struct config_params *cp, 
							 struct pbook_page *page, 
							 struct graphic_assembly_list *GA_list )
{
	struct change_book cb;
	struct change_spec ch_spec;

	if ( page->num_GAs <= 1 ) return;

	initChangeBook ( cp, page, &cb, GA_list );
	printf("change book initialized\n");

	findBestChange ( &cb, &ch_spec );

	while ( ch_spec.change_pending ) {

		reportChange ( &ch_spec );

		// execute the change, and update the change book
		executeChange ( cp, page, &cb, &ch_spec, GA_list );

		// find the best change in the change book
		findBestChange ( &cb, &ch_spec );

	}

	delete [] cb.cbe;
}


static void executeChange ( struct config_params *cp, 
						    struct pbook_page *page, 
						    struct change_book *cb, struct change_spec *ch_spec, 
							struct graphic_assembly_list *GA_list )
{
	int test;

	// make the change in the pbook
	if ( ch_spec->change_pending == MOVE ) {
		test = executeMove ( cp, page, cb, ch_spec, GA_list );
	}
	else {
		test = executeTrade ( cp, page, cb, ch_spec, GA_list );
	}

	if ( test == FAIL ) {
		exitOrException("\na change was allowed but it could not be executed");
	}

	// update potential changes in the change book
	updateChangeBook ( cp, page, cb, GA_list );
}


static int executeTrade ( struct config_params *cp, 
						  struct pbook_page *page,
						  struct change_book *cb, struct change_spec *ch_spec, 
						  struct graphic_assembly_list *GA_list )
{
	struct potential_trade *ch_spec_ptd;					// points into the change spec
	int GA_index, exch_GA_index;					// obtained from change spec
	struct change_book_entry *src_cbe, *exch_cbe;
	double actual_score_change;

	ch_spec_ptd = &( ch_spec->cbe.ptd );
	if ( !( ch_spec_ptd->is_allowed ) ) {
		exitOrException("\nunable to execute trade that is not allowed");
	}
	GA_index = ch_spec->cbe.subT_ID.GA_index;
	exch_GA_index = ch_spec_ptd->exch_subT_ID.GA_index; 

	// get the source page and record the negative of the page score
	actual_score_change = 0.0 - page->page_L.score;

	// remove GAs from page
	if ( removeGAFromPage ( cp, page, GA_index, GA_list ) == FAIL ) {
		return FAIL;
	}
	if ( removeGAFromPage ( cp, page, exch_GA_index, GA_list ) == FAIL ) {
		return FAIL;
	}

	// re-insert the images in the prescribed order
	if ( ch_spec_ptd->this_GA_first ) {
		if ( addGAToPage ( cp, page, &( GA_list->GA[GA_index] ), 
							 ch_spec_ptd->subT_index, 
							 ch_spec_ptd->node_index, 
							 ch_spec_ptd->cut_dir, GA_list ) == FAIL ) {
			return FAIL;
		}
		if ( addGAToPage ( cp, page, &( GA_list->GA[exch_GA_index] ), 
							 ch_spec_ptd->exch_subT_ID.subT_index, 
							 ch_spec_ptd->exch_node_index, 
							 ch_spec_ptd->exch_cut_dir, GA_list ) == FAIL ) {
			return FAIL;
		}
	}
	else {
		if ( addGAToPage ( cp, page, &( GA_list->GA[exch_GA_index] ), 
							 ch_spec_ptd->exch_subT_ID.subT_index, 
							 ch_spec_ptd->exch_node_index, 
							 ch_spec_ptd->exch_cut_dir, GA_list ) == FAIL ) {
			return FAIL;
		}
		if ( addGAToPage ( cp, page, &( GA_list->GA[GA_index] ), 
							 ch_spec_ptd->subT_index, 
							 ch_spec_ptd->node_index, 
							 ch_spec_ptd->cut_dir, GA_list ) == FAIL ) {
			return FAIL;
		}
	}

	// make sure actual change in score is as recorded in change book
	actual_score_change += page->page_L.score; 
	if ( fabs ( actual_score_change - scoreChange ( ch_spec ) ) > EPSILON ) {
		printf("unexpected value for actual score change\n");
		return FAIL;
	}

	// the subT_indices for these two GA's may have changed
	src_cbe = cbEntryFromGAIndex ( cb, GA_index );
	src_cbe->subT_ID.subT_index = ch_spec_ptd->subT_index;
	exch_cbe = cbEntryFromGAIndex ( cb, exch_GA_index );
	exch_cbe->subT_ID.subT_index = ch_spec_ptd->exch_subT_ID.subT_index; 

	return PASS;
}


static int executeMove ( struct config_params *cp, 
						 struct pbook_page *page, 
						 struct change_book *cb, struct change_spec *ch_spec, 
						 struct graphic_assembly_list *GA_list )
{
	int GA_index;						// obtained from the change spec
	struct potential_move *ch_spec_pmv;		// points into the change spec
	double actual_score_change;
	struct change_book_entry *cbe;		// points directly into cb

	ch_spec_pmv = &( ch_spec->cbe.pmv );
	if ( !( ch_spec_pmv->is_allowed ) ) {
		exitOrException("\nunable to execute move that is not allowed");
	}
	GA_index = ch_spec->cbe.subT_ID.GA_index; 

	// get the source page and record (the negative of) its score
	actual_score_change = 0.0 - page->page_L.score;

	// remove the GA, and then add it back at the specified node
	if ( removeGAFromPage ( cp, page, GA_index, GA_list ) == FAIL ) {
		return FAIL; 
	}
	if ( addGAToPage ( cp, page, &( GA_list->GA[GA_index] ), 
						 ch_spec_pmv->subT_index, 
						 ch_spec_pmv->node_index, 
						 ch_spec_pmv->cut_dir, GA_list ) == FAIL ) {
		return FAIL;
	}

	// make sure actual change in score is as recorded in change spec
	actual_score_change += page->page_L.score;
	if ( fabs ( actual_score_change - scoreChange ( ch_spec ) ) > EPSILON ) {
		printf("unexpected value for actual score change\n");
		return FAIL;
	}

	// the subT_index for this GA may have changed
	cbe = cbEntryFromGAIndex ( cb, GA_index );
	cbe->subT_ID.subT_index = ch_spec_pmv->subT_index;

	return PASS;
}


static change_book_entry *cbEntryFromGAIndex ( struct change_book *cb, int GA_index )
{
	int found, i;
	struct change_book_entry *cbe, *requested_cbe;

	found = 0;
	for ( i = 0; i < cb->num_GAs; i++ ) {
		cbe = & ( cb->cbe[i] );

		if ( cbe->subT_ID.GA_index == GA_index ) {
			requested_cbe = cbe;
			found++;
		}
	}

	if ( found != 1 ) {
		exitOrException("\nerror getting change book entry from GA index");
	}

	return requested_cbe;
}


static void updateChangeBook ( struct config_params *cp, 
							   struct pbook_page *page, 
							   struct change_book *cb, 
							   struct graphic_assembly_list *GA_list )
{
	int i, GA_index;
	struct change_book_entry *cbe;
	struct potential_move *pmv;
	struct potential_trade *ptd;

	for ( i = 0; i < cb->num_GAs; i++ ) {
		cbe = & ( cb->cbe[i] );
		GA_index = cbe->subT_ID.GA_index;

		pmv = & ( cbe->pmv );
		evaluatePotentialMove ( cp, pmv, page, GA_index, GA_list );

		ptd = & ( cbe->ptd );
		evaluatePotentialTrade ( cp, ptd, page, cb, GA_index, GA_list );
	}
}


static void reportChange ( struct change_spec *ch_spec )
{
	if ( ch_spec->change_pending == MOVE ) {
		printf("move ");
	}
	else if ( ch_spec->change_pending == TRADE ) {
		printf("trad ");
	}
	else {
		exitOrException("\nerror reporting change");
	}

	printf("GA #%d, ",ch_spec->cbe.subT_ID.GA_index);
	printf("delta %lf",scoreChange(ch_spec));
	if ( ch_spec->change_pending == TRADE ) {
		printf(", exch GA #%d, ",ch_spec->cbe.ptd.exch_subT_ID.GA_index);
		if ( ch_spec->cbe.ptd.this_GA_first ) {
			printf("src  GA 1st");
		}
		else {
			printf("exch GA 1st");
		}
	}

	printf("\n");
}


static void findBestChange ( struct change_book *cb, struct change_spec *ch_spec )
{
	int i;
	struct change_book_entry *cbe;
	struct potential_move *pmv;
	struct potential_trade *ptd;

	// to begin, assume there are no changes to make
	ch_spec->change_pending = 0;

	for ( i = 0; i < cb->num_GAs; i++ ) {
		cbe = & ( cb->cbe[i] );

		// check the move of this image to the dest page
		pmv = & ( cbe->pmv );
		if ( moveIsBestChange ( pmv, ch_spec ) ) {
			ch_spec->change_pending = MOVE;
			ch_spec->cbe = *cbe;
		}

		// check the trade of this image to the dest page
		ptd = & ( cbe->ptd );
		if ( tradeIsBestChange ( ptd, ch_spec ) ) { 
			ch_spec->change_pending = TRADE;
			ch_spec->cbe = *cbe;
		}

	}
}


static int tradeIsBestChange ( struct potential_trade *ptd, struct change_spec *ch_spec )
{
	if ( ptd->is_allowed ) {
		if ( ptd->score_change > EPSILON ) {

			if ( ch_spec->change_pending == 0 ) {
				// if this is the first acceptable change, then accept it
				return 1;
			}
			else {
				if ( ptd->score_change > scoreChange ( ch_spec ) + EPSILON ) {
					// if this change is better than any yet observed, then accept it
					return 1;
				}
			}

		}
	}

	return 0;
}


static double scoreChange ( struct change_spec *ch_spec )
{
	if ( ch_spec->change_pending == MOVE ) {
		if ( ch_spec->cbe.pmv.is_allowed ) {
			return ch_spec->cbe.pmv.score_change;
		}
	}

	if ( ch_spec->change_pending == TRADE ) {
		if ( ch_spec->cbe.ptd.is_allowed ) {
			return ch_spec->cbe.ptd.score_change;
		}
	}

	exitOrException("\nerror determining current score change");

	return 0.0;
}


static int moveIsBestChange ( struct potential_move *pmv, struct change_spec *ch_spec )
{
	if ( pmv->is_allowed ) {
		if ( pmv->score_change > EPSILON ) {

			if ( ch_spec->change_pending == 0 ) {
				// if this is the first acceptable change, then accept it
				return 1;
			}
			else {
				if ( pmv->score_change > scoreChange ( ch_spec ) + EPSILON ) {
					// if this change is better than any yet observed, then accept it
					return 1;
				}
				if ( fabs ( pmv->score_change - scoreChange ( ch_spec ) ) < EPSILON ) {
					if ( ch_spec->change_pending == TRADE ) {
						// if this change yields an equal change in score to some trade, 
						// then accept this one (since moving is faster/simpler)
						return 1;
					}
				}
			}

		}
	}

	return 0;
}


static void initChangeBook ( struct config_params *cp, struct pbook_page *page, 
							 struct change_book *cb,
							 struct graphic_assembly_list *GA_list )
{
	// one change book entry for each graphic assembly
	cb->num_GAs = page->num_GAs;
	cb->cbe = new struct change_book_entry [ cb->num_GAs ];

	// we address a GA by its entry in the graphic assembly list,
	// since it may move from page to page during the optimization
	addGAsToChangeBook ( cp, page, cb );

	// evaluate all the potential or candidate changes, 
	// recording the info we want to keep
	initChanges ( cp, page, cb, GA_list );
}


static void initChanges ( struct config_params *cp, struct pbook_page *page, 
						  struct change_book *cb, 
						  struct graphic_assembly_list *GA_list )
{
	int i, GA_index;
	struct change_book_entry *cbe;
	struct potential_move *pmv;
	struct potential_trade *ptd;

	for ( i = 0; i < cb->num_GAs; i++ ) {
		cbe = & ( cb->cbe[i] );
		GA_index = cbe->subT_ID.GA_index;

		pmv = & ( cbe->pmv );
		evaluatePotentialMove ( cp, pmv, page, GA_index, GA_list );

		ptd = & ( cbe->ptd );
		evaluatePotentialTrade ( cp, ptd, page, cb, GA_index, GA_list );
	}
}


static void addGAsToChangeBook ( struct config_params *cp, 
								   struct pbook_page *page, 
								   struct change_book *cb )
{
	int i;
	struct change_book_entry *cbe;
	struct subT_identifier *subT_ID;

	// with each GA associate a change book entry 
	for ( i = 0; i < page->num_GAs; i++ ) {
		subT_ID = subTIDFromTreeValue ( page->page_T, page->num_GAs, i+1 );
		cbe = & ( cb->cbe[i] );
		cbe->subT_ID = *subT_ID;
	}
}


static void evaluatePotentialTrade ( struct config_params *cp, 
									 struct potential_trade *ptd, 
									 struct pbook_page *page, 
									 struct change_book *cb, int GA_index, 
									 struct graphic_assembly_list *GA_list )
{
	struct pbook_page reserve_page, scratch_page1, scratch_page2;
	int ptd_recorded, i, exch_GA_index; 
	struct change_book_entry *exch_cbe;

	// determine allowability of trade
	determineTradeAllowability ( & ( ptd->is_allowed ), page );
	if ( ! ( ptd->is_allowed ) ) return;

	// this trade will occur within the page, so the GAs on the page,
	// (other than the source GA) is exactly the set of exchange candidates. 
	// we will pick the exchange candidate for which the resulting improvement
	// in score is greatest.  we need two trials for each exchange candidate, 
	// since the change in score depends upon the order in which we add the GAs 
	// back to the page

	// copy the source page into a reserve page, and remove the source GA
	duplicatePage ( page,  &reserve_page );
	if ( removeGAFromPage ( cp, &reserve_page, GA_index, GA_list ) == FAIL ) {
		ptd->is_allowed = 0;
		clearPage ( cp, &reserve_page );
		return;
	}

	ptd_recorded = 0;
	for ( i = 0; i < cb->num_GAs; i++ ) {
		exch_cbe = & ( cb->cbe[i] );
		exch_GA_index = exch_cbe->subT_ID.GA_index;
		if ( exch_GA_index != GA_index ) {

			if ( GAsAreSimilarPhotos ( cp, &(GA_list->GA[GA_index]), 
									   &(GA_list->GA[exch_GA_index]),
									   &( page->sched ), GA_list ) ) {
				continue;
			}

			// this is an exchange candidate

			// get a copy of the source page with the source GA removed,
			// and remove the exchange GA 
			duplicatePage ( &reserve_page, &scratch_page1 );
			if ( removeGAFromPage ( cp, &scratch_page1, exch_GA_index, GA_list ) == FAIL ) {
				clearPage ( cp, &scratch_page1 );
				continue;
			}
			// we will use the resulting page twice, so make a copy of it
			duplicatePage ( &scratch_page1, &scratch_page2 );

			// first, try placing the source GA first
			tryPlacingTwoGAsOnPage ( cp, page, &scratch_page1, 1, &ptd_recorded, ptd,
									   GA_index, exch_GA_index, GA_list );

			// now try placing the exchange GA first
			tryPlacingTwoGAsOnPage ( cp, page, &scratch_page2, 0, &ptd_recorded, ptd,
									   GA_index, exch_GA_index, GA_list );

			clearPage ( cp, &scratch_page2 );
			clearPage ( cp, &scratch_page1 );

		}
	}

	if ( ptd_recorded < 1 ) {
		// did not find any trades that worked
		ptd->is_allowed = 0;
	}

	clearPage ( cp, &reserve_page );
}


static void tryPlacingTwoGAsOnPage ( struct config_params *cp, 
									   struct pbook_page *src_page, 
									   struct pbook_page *scratch_page,
									   int this_GA_first, 
									   int *ptd_recorded, struct potential_trade *ptd, 
									   int GA_index, int exch_GA_index, 
									   struct graphic_assembly_list *GA_list )
{
	int subT_index, node_index, cut_dir;
	int exch_subT_index, exch_node_index, exch_cut_dir;
	double score_change;

	if ( ( this_GA_first != 0 ) && ( this_GA_first != 1 ) ) {
		exitOrException("\nerror trying to place two GAs on a page");
	}

	if ( this_GA_first ) {
		if ( placeGAOnPage ( cp, scratch_page, GA_index, GA_list, &subT_index, 
							   &node_index, &cut_dir ) == FAIL ) {
			return;
		}
		if ( placeGAOnPage ( cp, scratch_page, exch_GA_index, GA_list, &exch_subT_index,
							   &exch_node_index, &exch_cut_dir ) == FAIL ) {
			return;
		}
	}
	else {
		if ( placeGAOnPage ( cp, scratch_page, exch_GA_index, GA_list, &exch_subT_index,
							   &exch_node_index, &exch_cut_dir ) == FAIL ) {
			return;
		}
		if ( placeGAOnPage ( cp, scratch_page, GA_index, GA_list, &subT_index, 
							   &node_index, &cut_dir ) == FAIL ) {
			return;
		}
	}

	score_change = scratch_page->page_L.score - src_page->page_L.score;

	if ( ( *ptd_recorded == 0 ) || 
		 ( ( *ptd_recorded > 0 ) && ( score_change > ptd->score_change ) ) ) {
		ptd->subT_index = subT_index;
		ptd->node_index = node_index;
		ptd->cut_dir = cut_dir;
		ptd->exch_subT_ID.GA_index = exch_GA_index;
		ptd->exch_subT_ID.subT_index = exch_subT_index;
		ptd->exch_node_index = exch_node_index;
		ptd->exch_cut_dir = exch_cut_dir;
		ptd->this_GA_first = this_GA_first;
		ptd->score_change = score_change;

		(*ptd_recorded)++;
	}
}


static double uncroppedPhotoAspect ( struct photo *ph )
{
	double aspect;

	if ( ( ph->height <= 0 ) || ( ph->width <= 0 ) ) {
		exitOrException("\ninvalid photo dimensions");
	}
	aspect = ((double)(ph->height)) / ((double)(ph->width));

	return aspect;
}

static void determineTradeAllowability ( int *is_allowed, struct pbook_page *src_page )
{
	*is_allowed = 1;

	// need at least two images on the page 
	if ( src_page->num_GAs <= 1 ) *is_allowed = 0;
}

static void clearCollectionSchedule ( struct collection_schedule *cs )
{
	int i;
	struct page_schedule *pg_sched;

	if ( cs->num_pages > 0 ) {
		if ( cs->pg_scheds != NULL ) {
			for ( i = 0; i < cs->num_pages; i++ ) {
				pg_sched = &( cs->pg_scheds[i] );
				clearPageSchedule ( pg_sched );
			}

			delete [] cs->pg_scheds;
		}
	}

	cs->num_pages = 0;
	cs->pg_scheds = NULL;
}

static void genPhotoGrpSpec ( struct page_schedule *input_pg_sched,
							  struct graphic_assembly_spec *GA_spec, 
							  struct integer_list *GA_index_list, 
							  struct graphic_assembly_list *GA_list )
{
	int i, GA_index;
	struct photo_grp_spec *ph_grp_spec;
	struct graphic_assembly *GA;
	struct photo_spec *ph_grp_ph_spec;
	struct photo *ph;
	struct graphic_element_schedule *GE_sched;

	// prepare graphic assembly specification
	GA_spec->GA_index = allocateOneNewGA ( GA_list );
	GA_spec->type = PHOTO_GRP;
	ph_grp_spec = &( GA_spec->ph_grp_spec );
	ph_grp_spec->num_photo_specs = GA_index_list->num_integers;
	ph_grp_spec->ph_specs = new struct photo_spec [ GA_index_list->num_integers ];

	// copy the photo spec info for each individual photo GA
	for ( i = 0; i < GA_index_list->num_integers; i++ ) {
		GA_index = GA_index_list->integers[i];
		GA = &( GA_list->GA[GA_index] );

		if ( typeOfGA ( GA ) != PHOTO ) {
			exitOrException ("\nerror generating consolidated page schedule");
		}

		ph = &( GA->ph );
		ph_grp_ph_spec = &( ph_grp_spec->ph_specs[i] );

		// set the GE_ID for the GA of type photo
		ph_grp_ph_spec->GE_ID = ph->GE_ID;
		ph_grp_ph_spec->filename = ph->filename;
		ph_grp_ph_spec->pixel_height = ph->height;
		ph_grp_ph_spec->pixel_width = ph->width;
		ph_grp_ph_spec->has_crop_region = ph->has_crop_region;
		ph_grp_ph_spec->crop_region = ph->crop_region;
		ph_grp_ph_spec->has_ROI = ph->has_ROI;
		ph_grp_ph_spec->ROI = ph->ROI;
		// record the relative area from the input_pg_sched
		GE_sched = GEScheduleFromGEID ( &(ph->GE_ID), input_pg_sched, GA_list );
		ph_grp_ph_spec->area = GE_sched->relative_area;
	}
}

static void runPageSchedulePlacementTrials ( struct config_params *cp, 
											 struct page_list *pg_list, 
											 struct page_schedule *pg_sched,
											 struct graphic_assembly_list *GA_list )
{
	int i, j;
	struct page_list prev_pg_list;
	struct page_schedule_entry *pse;
	struct pbook_page *prev_page;

	initPageList ( cp, pg_list );
	initPageList ( cp, &prev_pg_list );

	for ( i = 0; i < pg_sched->num_GAs; i++ ) {
		pse = &( pg_sched->pse[i] );

		if ( i == 0 ) {
			prev_page = &( prev_pg_list.pages[0] );
			runGAPlacementTrials ( cp, prev_page, pse, pg_list, GA_list );
		}
		else {
			// record pg_list in prev_pg_list, 
			// so we can use page_list as the current working list
			duplicatePagesInPageList ( pg_list, &prev_pg_list );
			clearPagesInPageList ( cp, pg_list );

			for ( j = 0; j < prev_pg_list.num_pages; j++ ) {
				prev_page = &( prev_pg_list.pages[j] );
				runGAPlacementTrials ( cp, prev_page, pse, pg_list, GA_list );
			}
		}
//		printf("\tadded GA number %d ... type ",pse->GA_index);printGAType(&(GA_list->GA[pse->GA_index]));printf("\n");

		clearPagesInPageList ( cp, &prev_pg_list );
	}

	deletePageList ( cp, &prev_pg_list );
	checkPageList ( cp, pg_list, pg_sched );
}

static int numPhotosInLargestPhotoGroup ( struct page_schedule *pg_sched, 
										  struct graphic_assembly_list *GA_list )
{
	int i, greatest_num_photos;
	struct graphic_assembly *GA;
	struct photo_grp *ph_grp;

	greatest_num_photos = 0;
	for ( i = 0; i < pg_sched->num_GAs; i++ ) {
		GA = ithGAInPageSchedule ( pg_sched, i, GA_list );

		if ( typeOfGA ( GA ) == PHOTO_GRP ) {
			ph_grp = &( GA->ph_grp );
			if ( greatest_num_photos < ph_grp->num_photos ) {
				greatest_num_photos = ph_grp->num_photos;
			}
		}
	}

	return ( greatest_num_photos );
}

static void printGAType ( struct graphic_assembly *GA )
{
	if ( typeOfGA ( GA ) == PHOTO ) printf("photo ");
	if ( typeOfGA ( GA ) == PHOTO_GRP ) printf("photo_grp ");
	if ( typeOfGA ( GA ) == PHOTO_VER ) printf("photo_ver ");
	if ( typeOfGA ( GA ) == PHOTO_SEQ ) printf("photo_seq ");
}


static void runGAPlacementTrials ( struct config_params *cp, struct pbook_page *prev_page,
								   struct page_schedule_entry *pse, struct page_list *pg_list,
								   struct graphic_assembly_list *GA_list )
{
	int i, j;
	struct graphic_assembly *GA;

	// for this GA, for this page from the prev_pg_list, 
	// generate a set of candidate layouts,
	// inserting them into current pg_list as appropriate

	addPageScheduleEntryToPageSchedule ( pse, &( prev_page->sched ) );
	computeTargetAreas ( cp, &( prev_page->sched ), GA_list );

	GA = &( GA_list->GA[pse->GA_index] );
	for ( i = 0; i < GA->num_subTs; i++ ) {
		if ( prev_page->num_GAs == 0 ) {
			runOneGAPlacementTrial ( cp, prev_page, GA, pg_list, GA_list, i, -1, -1 );
		}
		else {
			for ( j = 0; j < treeLen ( prev_page->num_GAs ); j++ ) {
				runOneGAPlacementTrial ( cp, prev_page, GA, pg_list, GA_list, i, j, VERT );
				runOneGAPlacementTrial ( cp, prev_page, GA, pg_list, GA_list, i, j, HORIZ );
			}
		}
	}
}


static void runOneGAPlacementTrial ( struct config_params *cp, struct pbook_page *prev_page,
								   struct graphic_assembly *GA, struct page_list *pg_list,
								   struct graphic_assembly_list *GA_list,
								   int subT_index, int node_index, int cut_dir )
{
	struct pbook_page test_page;
	int result;

	initPage ( cp, &test_page );
	duplicatePage ( prev_page, &test_page );

	// modify prev_page in the prescribed way to create test_page
	result = addGAToPage ( cp, &test_page, GA, subT_index, node_index, cut_dir, GA_list );

	if ( result == PASS ) {
		// add test_page to pg_list if appropriate (depends on pages in pg_list)
		submitPageToPageList ( cp, &test_page, pg_list );
	}

	clearPage ( cp, &test_page );
}

static void submitPageToPageList ( struct config_params *cp, struct pbook_page *test_page,
								   struct page_list *pg_list )
{
	int i, same_score_found;
	struct pbook_page *page;

	same_score_found = 0;

	for ( i = 0; i < pg_list->num_pages; i++ ) {
		page = &( pg_list->pages[i] );

		// determine whether test_page and page have the same score
		if ( fabs ( test_page->page_L.score - page->page_L.score ) < EPSILON ) {
			same_score_found = 1;
		}
	}

	// if there is no page in the page list with the exact same score
	// (e.g. if the current page is not a reflection of any other page),
	// then insert test_page into the page list based on its score
	if ( same_score_found == 0 ) {
		addPageToPageList ( cp, test_page, pg_list );
	}
}


static void addPageToPageList ( struct config_params *cp, struct pbook_page *test_page,
							    struct page_list *pg_list )
{
	int rank, i;
	struct pbook_page *page;

	if ( pg_list->num_pages < 0 ) {
		exitOrException("\nunable to add page to page list ... invalid num_pages");
	}

	if ( pg_list->num_pages == 0 ) {
		rank = 0;
	}
	else {
		rank = -1;
		for ( i = 0; i < pg_list->num_pages; i++ ) {
			page = &( pg_list->pages[i] );

			if ( test_page->page_L.score > page->page_L.score ) {
				// test_page will take this place in page_list
				rank = i;
				break;
			}
		}
	}

	// if page_list is not full yet, we can still put test_page into page_list, 
	// even if test_page didn't beat any of the pages in the page list,
	if ( rank == -1 ) {
		if ( pg_list->num_pages < cp->NUM_WORKING_LAYOUTS ) {
			rank = pg_list->num_pages;
		}
	}

	if ( rank >= 0 ) {
		// if page_list is not full, increment the list length 
		if ( pg_list->num_pages < cp->NUM_WORKING_LAYOUTS ) {
			(pg_list->num_pages)++;
		}

		for ( i = pg_list->num_pages - 1; i > rank; i-- ) {
			clearPage ( cp, &( pg_list->pages[i] ) );
			duplicatePage ( &( pg_list->pages[i-1] ), &( pg_list->pages[i] ) );
		}
		clearPage ( cp, &(pg_list->pages[rank] ) );
		duplicatePage ( test_page, &( pg_list->pages[rank] ) );
	}
}


static void removePageFromPageList ( struct config_params *cp, struct pbook_page *page, 
									 struct page_list *pg_list )
{
	int count, i, index;

	if ( pg_list->num_pages <= 0 ) {
		exitOrException("\nunable to remove page from page list with invalid num_pages");
	}

	// identify index of page in page_list
	count = 0;
	for ( i = 0; i < pg_list->num_pages; i++ ) {
		if ( page == &( pg_list->pages[i] ) ) {
			index = i;
			count++;
		}
	}
	if ( count != 1 ) {
		exitOrException("\nunable to find page in page_list so could not remove page");
	}

	for ( i = index; i < pg_list->num_pages - 1; i++ ) {
		clearPage ( cp, &( pg_list->pages[i] ) );
		duplicatePage ( &( pg_list->pages[i+1] ), &( pg_list->pages[i] ) );
	}
	clearPage ( cp, &( pg_list->pages[pg_list->num_pages-1] ) );

	(pg_list->num_pages)--;
}

static void checkPageList ( struct config_params *cp, struct page_list *pg_list,
						    struct page_schedule *pg_sched )
{
	int i, j, GA_index;
	struct pbook_page *page, *page_before;
	struct page_schedule_entry *pse;

	// the page schedule should have at least one GA
	if ( pg_sched->num_GAs <= 0 ) {
		exitOrException("\nunable to check page_list - empty page_schedule");
	}

	// there should be at least one page
	if ( pg_list->num_pages <= 0 ) {
		exitOrException("\nunable to create a layout for a page");
	}

	// each page should have all the GA's in the pg_sched
	for ( i = 0; i < pg_list->num_pages; i++ ) {
		page = &( pg_list->pages[i] );

		if ( page->num_GAs != pg_sched->num_GAs ) {
			exitOrException("\npage list has layout with wrong number of GA's");
		}

		for ( j = 0; j < pg_sched->num_GAs; j++ ) {
			pse = &( pg_sched->pse[j] );
			GA_index = pse->GA_index;

			if ( !GAIsOnPage ( page, GA_index ) ) {
				exitOrException("\ncheck page list failed - layout lacks one of the scheduled GA's");
			}
		}
	}

	// pages should be in order of decreasing score
	for ( i = 1; i < cp->NUM_WORKING_LAYOUTS; i++ ) {
		page = &( pg_list->pages[i] );
		if ( page->num_GAs > 0 ) {
			page_before = &( pg_list->pages[i-1] );
			if ( page_before->page_L.score < page->page_L.score - EPSILON ) {
				exitOrException("\nexpect page_list to have pages in order of decreasing score");
			}
		}
	}
}

static double usableArea ( struct config_params *cp )
{
	return ( ( usableHeight ( cp ) ) * ( usableWidth ( cp ) ) );
}

static double usableHeight ( struct config_params *cp )
{
	double height;

	height = cp->pageHeight - ( cp->topMargin + cp->bottomMargin );

	if ( height < EPSILON ) {
		exitOrException("\npage height incompatible with margins");
	}

	return ( height );
}

static double usableWidth ( struct config_params *cp )
{
	double width;

	width = cp->pageWidth - ( cp->rightMargin + cp->leftMargin );

	if ( width < EPSILON ) {
		exitOrException("\npage width incompatible with margins");
	}

	return ( width );
}

static void clearPagesInPageList ( struct config_params *cp, struct page_list *pg_list )
{
	int i;

	for ( i = 0; i < pg_list->num_pages; i++ ) {
		clearPage ( cp, &( pg_list->pages[i] ) );
	}

	pg_list->num_pages = 0;
}

void deletePageList ( struct config_params *cp, struct page_list *pg_list )
{
	if ( pg_list->num_pages > 0 ) {
		if ( pg_list->pages != NULL ) {
			clearPagesInPageList ( cp, pg_list );
			delete [] pg_list->pages;
		}
	}

	pg_list->num_pages = 0;
	pg_list->pages = NULL;
}

static void deletePageListSequence ( struct config_params *cp,
									struct page_list_sequence *pls )
{
	int i;
	struct page_list *pg_list;

	if ( pls->num_page_lists > 0 ) {
		for ( i = 0; i < pls->num_page_lists; i++ ) {
			pg_list = pls->page_lists[i];
			deletePageList ( cp, pg_list );
		}
	}

	pls->num_page_lists = 0;
	pls->page_lists = NULL;
}

static void clearPageTree ( struct pbook_page *page )
{
	if ( page->num_GAs > 0 ) {
		if ( page->page_T != NULL ) {
			delete [] page->page_T;
		}
	}

	page->page_T = NULL;
}

static void clearLayout ( struct layout *L )
{
	if ( L->num_VPs > 0 ) {
		if ( L->VPs != NULL ) {
			delete [] L->VPs;
		}
	}

	L->num_VPs = 0;
	L->VPs = NULL;
	L->score = 0.0;
}

static void clearPageScheduleEntry ( struct page_schedule_entry *pse )
{
	if ( pse->num_GEs > 0 ) {
		if ( pse->GE_scheds != NULL ) {
			delete [] pse->GE_scheds;
		}
	}

	pse->GA_index = -1;
	pse->num_GEs = 0;
	pse->GE_scheds = NULL;
}

static void clearPageSchedule ( struct page_schedule *pg_sched )
{
	int i;
	struct page_schedule_entry *pse;

	if ( pg_sched->num_GAs > 0 ) {
		if ( pg_sched->pse != NULL ) {
			for ( i = pg_sched->num_GAs - 1; i >= 0; i-- ) {
				pse = &( pg_sched->pse[i] );
				clearPageScheduleEntry ( pse );
			}
			delete [] pg_sched->pse;
		}
	}

	pg_sched->num_GAs = 0;
	pg_sched->pse = NULL;
}

static void clearPage ( struct config_params *cp, struct pbook_page *page )
{
	// delete all allocated arrays and reset all variable values

	clearPageTree ( page );
	clearLayout ( &( page->page_L ) );
	clearPageSchedule ( &( page->sched ) );

	page->num_GAs = 0;
	page->usable_height = 0.0;
	page->usable_width = 0.0;
	page->rotation_count = 0;

	page->usable_height = usableHeight ( cp );
	page->usable_width = usableWidth ( cp );
}

static void initPageList ( struct config_params *cp, struct page_list *pg_list )
{
	int i;

	pg_list->num_pages = 0;
	pg_list->pages = new struct pbook_page [ cp->NUM_WORKING_LAYOUTS ];

	for ( i = 0; i < cp->NUM_WORKING_LAYOUTS; i++ ) {
		initPage ( cp, &( pg_list->pages[i] ) );
	}
}

static void initPage ( struct config_params *cp, struct pbook_page *page )
{
	// initialize a page struct that has not been used yet

	// zero out these variables 
	// so the routines in clearPage will not try to free corresponding arrays
	page->num_GAs = 0;
	page->page_L.num_VPs = 0;
	page->sched.num_GAs = 0;

	clearPage ( cp, page );
}

static int computeObjAreas ( struct config_params *cp, struct pbook_page *page, 
							 struct graphic_assembly_list *GA_list )
{
	struct GE_treeNode *GE_tree;

	// determine height and width for each graphic element,
	// and determine a layout score

	page->page_L.score = 0.0;

	if ( page->num_GAs < 1 ) {
		return PASS;
	}

	// from the subT_tree in the page structure (i.e. page_T), create a 
	// more detailed tree whose leaves are graphic elements (not GAs)
	GE_tree = new struct GE_treeNode [ treeLen ( page->page_L.num_VPs ) ];
	subTToGE ( cp, GE_tree, page, page->page_L.num_VPs, GA_list );

	// determine photo areas with any subset having fixed areas,
	// and controlling distances between neighboring photos
	if ( computeObjAreasBRIC ( cp, page, GE_tree, GA_list ) == FAIL ) {
		delete [] GE_tree;
		return FAIL;
	}
	FAInitTermNodeBBs ( cp, GE_tree, &( page->page_L ), GA_list );
	FAAccumBBs ( cp, GE_tree, page->page_L.num_VPs, GE_tree[0].value );

	page->page_L.score = layoutScore ( cp, page, GE_tree, GA_list );

	delete [] GE_tree;
	return PASS;
}

static int computeObjAreasBRIC ( struct config_params *cp, struct pbook_page *page, 
								 struct GE_treeNode *GE_tree,
								 struct graphic_assembly_list *GA_list )
{
	int num_GEs, row_count, test_result, horiz_test_result, vert_test_result;
	double **a, *b, *horiz_areas_solution, *vert_areas_solution;
	struct path h_p, v_p;

	// if there are no GE's there is nothing to do
	num_GEs = page->page_L.num_VPs;
	if ( num_GEs <= 0 ) return PASS;

	// allocate space for the tableau
	allocateMatrices ( &a, &b, num_GEs );

	// for each nonleaf node, add one row to the tableau, 
	// starting at row 1 (row 0 is reserved for use below)
	row_count = 1;
	populateAreaTableau ( cp, page, GE_tree, GA_list, GE_tree[0].value, a, b, &h_p, &v_p, &row_count );
	if ( row_count != num_GEs ) {
		exitOrException("\nerror populating matrices for computing object areas");
	}

	// the tableau is not complete - need to add one more constraint - there
	// are two we can add, but we don't know yet which will yield an acceptable answer, 
	// so we need to try both 

	// constrain width of layout to equal width of usable area
	finishAreaTableau ( page, GE_tree, GA_list, &h_p, a, b );
	horiz_areas_solution = new double [ num_GEs ];
	computeSolutionVector ( a, b, horiz_areas_solution, page->page_L.num_VPs );
	horiz_test_result = testAreasSolution ( cp, page, GE_tree, GA_list, horiz_areas_solution, &h_p, &v_p );

	// constrain height of layout to equal height of usable area
	finishAreaTableau ( page, GE_tree, GA_list, &v_p, a, b );
	vert_areas_solution = new double [ num_GEs ];
	computeSolutionVector ( a, b, vert_areas_solution, page->page_L.num_VPs );
	vert_test_result = testAreasSolution ( cp, page, GE_tree, GA_list, vert_areas_solution, &h_p, &v_p );

	// select a solution based on the test results
	test_result = FAIL;
	if ( horiz_test_result == PASS ) {
		recordAreasFromSolnVec ( &( page->page_L ), horiz_areas_solution, GE_tree, GA_list );
		test_result = PASS;
	}
	else if ( vert_test_result == PASS ) {
		recordAreasFromSolnVec ( &( page->page_L ), vert_areas_solution, GE_tree, GA_list );
		test_result = PASS;
	}

	delete [] vert_areas_solution;
	delete [] horiz_areas_solution;
	delete [] v_p.nodes;
	delete [] h_p.nodes;
	deleteMatrices ( a, b, num_GEs );

	return test_result;
}


static void populateAreaTableau ( struct config_params *cp, 
								  struct pbook_page *page, struct GE_treeNode *GE_tree, 
								  struct graphic_assembly_list *GA_list,
								  int node_value, double **a, double *b,
								  struct path *h_p, struct path *v_p, int *count )
{
	int num_GEs;
	struct GE_treeNode *node, *Lchild, *Rchild;
	struct path L_h_p, L_v_p, R_h_p, R_v_p, *L_p, *R_p;
	double *a_row, *b_row;

	num_GEs = page->page_L.num_VPs;
	node = GETreeNode ( GE_tree, node_value, num_GEs );
	if ( node->value > 0 ) {
		startPathsForAreaTableau ( h_p, v_p, node, &( page->sched ), GA_list );
		return;
	}

	// process the children of this node 
	Lchild = GETreeLeftChild ( GE_tree, node, num_GEs );
	Rchild = GETreeRightChild ( GE_tree, node, num_GEs );
	populateAreaTableau ( cp, page, GE_tree, GA_list, Lchild->value, a, b, &L_h_p, &L_v_p, count );
	populateAreaTableau ( cp, page, GE_tree, GA_list, Rchild->value, a, b, &R_h_p, &R_v_p, count );

	// combine the paths of the children to create paths of the current node
	if ( node->cut_dir == VERT ) {
		concatenatePaths ( cp, GE_tree, num_GEs, h_p, &L_h_p, &R_h_p, node ); 
		if ( L_v_p.fixed_dist >= R_v_p.fixed_dist ) copyPath ( v_p, &L_v_p );
		else										copyPath ( v_p, &R_v_p );
	}
	else {
		concatenatePaths ( cp, GE_tree, num_GEs, v_p, &L_v_p, &R_v_p, node ); 
		if ( L_h_p.fixed_dist >= R_h_p.fixed_dist ) copyPath ( h_p, &L_h_p );
		else										copyPath ( h_p, &R_h_p );
	}

	// incorporate the constraint of this node into the tableau
	if ( node->cut_dir == VERT ) { L_p = &( L_v_p ); R_p = &( R_v_p ); }
	else						 { L_p = &( L_h_p ); R_p = &( R_h_p ); }
	if ( *count >= num_GEs ) {
		exitOrException("\nerror populating matrices for computing object areas");
	}
	a_row =    a[(*count)]  ;
	b_row = &( b[(*count)] );
	putPathIntoAreaTableauRow ( GE_tree, num_GEs, GA_list, L_p, a_row, b_row,  1.0 );
	putPathIntoAreaTableauRow ( GE_tree, num_GEs, GA_list, R_p, a_row, b_row, -1.0 );

	// increment counter so the next constraint will be written in a different row
	(*count)++;

	delete [] L_h_p.nodes;
	delete [] L_v_p.nodes;
	delete [] R_h_p.nodes;
	delete [] R_v_p.nodes;
}

static int testDistancesSolution ( struct GE_treeNode *GE_tree,
								   double *computed_distances, struct path *p, 
								   struct GE_identifier *GEIDs, int num_GEs,
								   double target_path_length )
{
	int i, index;
	double dist;
	struct GE_treeNode *node;

	if ( num_GEs <= 0 ) {
		exitOrException("\nerror testing distances solution");
	}

	if ( aValueIsNotPositive ( computed_distances, num_GEs ) ) {
		return FAIL;
	}

	if ( ( p->dir != HORIZ ) && ( p->dir != VERT ) ) {
		exitOrException("\nerror testing distances solution");
	}

	dist = 0.0;
	for ( i = 0; i < p->num_steps; i++ ) {
		node = GETreeNode ( GE_tree, p->nodes[i], num_GEs );

		if ( node->value <= 0 ) {
			dist += node->cut_spacing;
		}
		else {
			index = indexOfGAInListOfGEIDs ( node->GA_index, GEIDs, num_GEs ); 
			dist += computed_distances[index];
			dist += ( 2.0 * node->border );
		}
	}

	if ( fabs ( dist - target_path_length ) > EPSILON ) {
		exitOrException("\ndistances solution does not lead to required path length");
	}

	return PASS;
}


static int testAreasSolution ( struct config_params *cp, struct pbook_page *page, 
							   struct GE_treeNode *GE_tree, 
							   struct graphic_assembly_list *GA_list, double *solution, 
							   struct path *h_path, struct path *v_path )
{
	struct layout test_L;
	double h_dist, v_dist;

	if ( page->page_L.num_VPs <= 0 ) {
		exitOrException("\nerror testing areas solution");
	}

	// the values in the solution vector are the square roots of the
	// object areas ... if any value is not positive the layout cannot be realized
	if ( aValueIsNotPositive ( solution, page->page_L.num_VPs ) ) {
		return FAIL;
	}

	if ( ( h_path->dir != HORIZ ) || ( v_path->dir != VERT ) ) {
		exitOrException("\nerror testing solution for object areas");
	}

	// if the length of a path exceeds the available area,
	// the layout does not fit
	test_L.VPs = NULL;
	copyLayout ( &( page->page_L ), &test_L );
	recordAreasFromSolnVec ( &test_L, solution, GE_tree, GA_list );
	h_dist = pathDistance ( cp, &test_L, GE_tree, h_path );
	v_dist = pathDistance ( cp, &test_L, GE_tree, v_path );
	clearLayout ( &test_L );

	if ( ( h_dist < 0.0 - EPSILON ) || ( h_dist > page->usable_width + EPSILON ) ) {
		return FAIL;
	}
	if ( ( v_dist < 0.0 - EPSILON ) || ( v_dist > page->usable_height + EPSILON ) ) {
		return FAIL;
	}

	return PASS;
}


static double pathDistance ( struct config_params *cp, struct layout *L, 
							 struct GE_treeNode *GE_tree, struct path *p )
{
	double dist;
	int i, index;
	struct GE_treeNode *node;
	struct physical_rectangle *p_rect;

	dist = 0.0;
	for ( i = 0; i < p->num_steps; i++ ) {
		index = GEGetTreeIndex ( GE_tree, treeLen ( L->num_VPs ), p->nodes[i] );
		node = & ( GE_tree[index] );

		if ( node->value <= 0 ) {
			dist += node->cut_spacing;
		}
		else {
			p_rect = physRectFromGEID ( &( node->GE_ID ), L );
			verifyPhysRectDimensions ( p_rect );

			if ( p->dir == HORIZ ) { dist += p_rect->width;  }
			else				   { dist += p_rect->height; }
			dist += ( 2.0 * node->border );
		}
	}

	if ( dist < 0.0 - EPSILON ) {
		exitOrException("\ninvalid path distance");
	}

	return dist;
}


static void recordAreasFromSolnVec ( struct layout *L, double *solution,
									 struct GE_treeNode *GE_tree,
									 struct graphic_assembly_list *GA_list )
{
	int i, GE_index;
	double GE_aspect, GE_area;
	struct GE_identifier *GE_ID;
	struct physical_rectangle *p_rect;

	for ( i = 0; i < L->num_VPs; i++ ) {
		GE_index = GEGetTreeIndex ( GE_tree, treeLen ( L->num_VPs ), i+1 );
		GE_ID = &( GE_tree[GE_index].GE_ID );

		GE_aspect = GEAspectFromGAList ( GE_ID, GA_list );

		// the index into the solution vector, that corresponds to this
		// GE_index, is i+1-1 = i
		//
		// remember, the solution vector holds the square root of the area
		GE_area = solution[i] * solution[i];

		p_rect = physRectFromGEID ( GE_ID, L );
		p_rect->height = sqrt ( GE_area * GE_aspect );
		p_rect->width  = sqrt ( GE_area / GE_aspect );

		// for now, assign feasible values for the bottom and left 
		p_rect->vert_offset = p_rect->horiz_offset = 0.0;
	}
}


static int aValueIsNotPositive ( double *x, int N )
{
	int i;

	for ( i = 0; i < N; i++ ) {
		if ( x[i] < EPSILON ) { return 1; }
	}

	return 0;
}

static void computeSolutionVector ( double **a, double *b, double *solution, int dimension )
{
	int i;
	double **temp_a, *temp_b;

	// copy tableau into scratch space
	allocateMatrices ( &temp_a, &temp_b, dimension );
	copyMatrices ( a, temp_a, b, temp_b, dimension );

	// solve the system and record the solution
	solveLinearSystem ( temp_a, temp_b, dimension );
	for ( i = 0; i < dimension; i++ ) {
		solution[i] = temp_b[i];
	}

	deleteMatrices ( temp_a, temp_b, dimension );
}


static void finishAreaTableau ( struct pbook_page *page, struct GE_treeNode *GE_tree,
								struct graphic_assembly_list *GA_list,
								struct path *p, double **a, double *b )
{
	double *a_row, *b_row;
	int num_GEs, i;

	a_row =		a[0]  ;
	b_row = & ( b[0] );

	// clear the row since putPathIntoAreaTableauRow will incorporate coefficients 
	// by adding them, rather than writing over what is already there
	num_GEs = page->page_L.num_VPs;
	for ( i = 0; i < num_GEs; i++ ) { a_row[i] = 0.0; }
	*b_row = 0;

	if ( p->dir == HORIZ )	{ *b_row += page->usable_width;  }
	else					{ *b_row += page->usable_height; }

	putPathIntoAreaTableauRow ( GE_tree, num_GEs, GA_list, p, a_row, b_row, 1.0 );
}


static void putPathIntoAreaTableauRow ( struct GE_treeNode *GE_tree, int num_GEs, 
										struct graphic_assembly_list *GA_list,
										struct path *p, double *a_row, double *b_row, 
										double sign )
{
	int i, tree_index, col_index; 
	struct GE_treeNode *node;

	checkSign ( sign );

	for ( i = 0; i < p->num_steps; i++ ) {
		if ( p->nodes[i] > 0 ) {

			tree_index = GEGetTreeIndex ( GE_tree, treeLen ( num_GEs ), p->nodes[i] );
			node = & ( GE_tree[ tree_index ] );
			col_index = node->value - 1;

			if ( p->dir == HORIZ ) {
				a_row[col_index] += sign / 
									sqrt ( GEAspectFromGAList ( &(node->GE_ID), GA_list ) );
			}
			else {
				a_row[col_index] += sign * 
									sqrt ( GEAspectFromGAList ( &(node->GE_ID), GA_list ) );
			}

		}
	}

	*b_row -= sign * ( p->fixed_dist );
}


static void checkSign ( double sign )
{
	if ( ( fabs ( sign - 1.0 ) > EPSILON ) && 
		 ( fabs ( sign + 1.0 ) > EPSILON ) ) {
		exitOrException("\nsign must be either 1.0 or -1.0");
	}
}


static void copyMatrices ( double **a, double **temp_a,
						   double *b, double *temp_b, int N )
{
	int i, j;

	for ( i = 0; i < N; i++ ) {
		for ( j = 0; j < N; j++ ) { temp_a[i][j] = a[i][j]; }
		temp_b[i] = b[i];
	}
}


static void allocateMatrices ( double ***a, double **b, int N )
{
	int i;

	*a = new double * [ N ];
	for ( i = 0; i < N; i++ ) { (*a)[i] = new double [ N ]; }
	*b = new double [ N ];
	clearMatrices ( *a, *b, N );
}


static void deleteMatrices ( double **a, double *b, int N )
{
	int i;

	delete [] b;
	for ( i = N - 1; i >= 0; i-- ) { delete [] ( a[i] ); }
	delete [] a;
}


static void clearMatrices ( double **a, double *b, int N )
{
	int i, j;

	if ( N <= 0 ) { exitOrException("\ncan't clear matrices"); }

	for ( i = 0; i < N; i++ ) {
		for ( j = 0; j < N; j++ ) { a[i][j] = 0.0; }
		b[i] = 0.0;
	}
}

static void MAP_deleteBrickEqnPaths ( struct path *paths, int num_GEs )
{
	int i;

	for ( i = 0; i < 2 * num_GEs; i++ ) {
		delete [] paths[i].nodes;
	}
	delete [] paths;
}

static void concatenatePaths ( struct config_params *cp, struct GE_treeNode *GE_tree, 
							   int num_GEs, 
							   struct path *to_path, struct path *L_from_path, 
							   struct path *R_from_path, struct GE_treeNode *node )
{
	int i, node_index;

	to_path->dir = L_from_path->dir;
	to_path->num_steps = L_from_path->num_steps + 1 + R_from_path->num_steps;
	to_path->nodes = new int [ to_path->num_steps ];
	for ( i = 0; i < L_from_path->num_steps; i++ ) {
		to_path->nodes[i] = L_from_path->nodes[i];
	}
	to_path->nodes[ L_from_path->num_steps ] = node->value;
	for ( i = 0; i < R_from_path->num_steps; i++ ) {
		node_index = L_from_path->num_steps + 1 + i;
		to_path->nodes[node_index] = R_from_path->nodes[i];
	}
	to_path->fixed_dist = L_from_path->fixed_dist + node->cut_spacing + R_from_path->fixed_dist;
	to_path->var_dist_term = L_from_path->var_dist_term + R_from_path->var_dist_term;
}


static void copyPath ( struct path *to_path, struct path *from_path )
{
	int i;

	to_path->dir = from_path->dir;
	to_path->num_steps = from_path->num_steps;
	to_path->nodes = new int [ from_path->num_steps ];
	for ( i = 0; i < from_path->num_steps; i++ ) {
		to_path->nodes[i] = from_path->nodes[i];
	}
	to_path->fixed_dist	   = from_path->fixed_dist;
	to_path->var_dist_term = from_path->var_dist_term;
}

static void startPathsForAreaTableau ( struct path *h_p, struct path *v_p, 
									   struct GE_treeNode *node,
									   struct page_schedule *pg_sched,
									   struct graphic_assembly_list *GA_list )
{
	// create a vert path and a horiz path 
	// each with only one step through the photo

	h_p->dir = HORIZ;
	h_p->num_steps = 1;
	h_p->nodes = new int [ 1 ];
	h_p->nodes[0] = node->value;
	h_p->var_dist_term = h_p->fixed_dist = 0.0;
	h_p->var_dist_term += GERelativeWidth ( &( node->GE_ID ), pg_sched, GA_list );

	v_p->dir = VERT;
	v_p->num_steps = 1;
	v_p->nodes = new int [ 1 ];
	v_p->nodes[0] = node->value;
	v_p->var_dist_term = v_p->fixed_dist = 0.0;
	v_p->var_dist_term += GERelativeHeight ( &( node->GE_ID ), pg_sched, GA_list );

	// add border to the fixed distances
	h_p->fixed_dist += ( 2.0 * node->border );
	v_p->fixed_dist += ( 2.0 * node->border );
}

static double layoutScore ( struct config_params *cp, struct pbook_page *page, 
						    struct GE_treeNode *GE_tree,
							struct graphic_assembly_list *GA_list )
{
	return targetAreaScore ( page, GA_list );
}

static double relativeAreaOfPageScheduleEntry ( struct page_schedule_entry *pse,
											    struct graphic_assembly_list *GA_list )
{
	int i, GA_index;
	double relative_area;
	struct graphic_assembly *GA;
	struct graphic_element_schedule *GE_sched;

	if ( pse->num_GEs < 1 ) {
		exitOrException("\nerror computing relative area of page schedule entry");
	}

	relative_area = 0.0;
	GA_index = pse->GA_index;
	GA = &( GA_list->GA[GA_index] );
	if ( ( typeOfGA(GA) == PHOTO ) || ( typeOfGA(GA) == PHOTO_SEQ ) || ( typeOfGA(GA) == PHOTO_GRP ) ) {
		for ( i = 0; i < pse->num_GEs; i++ ) {
			GE_sched = &( pse->GE_scheds[i] );
			if ( GE_sched->relative_area < EPSILON ) {
				exitOrException("\nerror computing relative area of page schedule entry");
			}
			relative_area += GE_sched->relative_area;
		}
	}
	else if ( ( typeOfGA(GA) == PHOTO_VER ) || ( typeOfGA(GA) == FIXED_DIM ) ) {
		for ( i = 0; i < pse->num_GEs; i++ ) {
			GE_sched = &( pse->GE_scheds[i] );
			if ( GE_sched->relative_area < EPSILON ) {
				exitOrException("\nerror computing relative area of page schedule entry");
			}
			relative_area += GE_sched->relative_area;
		}
		relative_area /= ((double)(pse->num_GEs));
	}
	else {
		exitOrException("\nerror computing relative area of page schedule entry");
	}

	if ( relative_area < EPSILON ) {
		exitOrException("\nerror computing relative area of page schedule entry");
	}

	return ( relative_area );
}

static double photoRelativeAreaFromPageSchedule ( struct page_schedule *pg_sched,
												  struct graphic_assembly_list *GA_list )
{
	int i, GA_index;
	double area;
	struct page_schedule_entry *pse;
	struct graphic_assembly *GA;

	area = 0.0;
	for ( i = 0; i < pg_sched->num_GAs; i++ ) {
		pse = &( pg_sched->pse[i] );
		GA_index = pse->GA_index;
		GA = &( GA_list->GA[GA_index] );
		if ( ( typeOfGA ( GA ) == PHOTO ) || ( typeOfGA ( GA ) == PHOTO_SEQ ) ||
			 ( typeOfGA ( GA ) == PHOTO_VER ) || ( typeOfGA ( GA ) == PHOTO_GRP ) ) {
			area += relativeAreaOfPageScheduleEntry ( pse, GA_list );
		}
	}

	return ( area );
}

static double averageTargetAreaOfFixedDimensionsGA ( struct page_schedule_entry *pse,
													 struct graphic_assembly_list *GA_list )
{
	int i, GA_index;
	double sum;
	struct graphic_element_schedule *GE_sched;
	struct graphic_assembly *GA;

	GA_index = pse->GA_index;
	GA = &( GA_list->GA[GA_index] );
	if ( typeOfGA ( GA ) != FIXED_DIM ) {
		exitOrException("\nerror computing average area of fixed dimensions GA");
	}
	if ( pse->num_GEs < 1 ) {
		exitOrException("\nerror computing average area of fixed dimensions GA");
	}

	sum = 0.0;
	for ( i = 0; i < pse->num_GEs; i++ ) {
		GE_sched = &( pse->GE_scheds[i] );
		if ( GE_sched->target_area < EPSILON ) {
			exitOrException("\nerror computing average area of fixed dimensions GA");
		}

		sum += GE_sched->target_area;
	}

	return ( sum / ((double)(pse->num_GEs)) );
}

static int numberOfFixedDimensionsGAs ( struct page_schedule *pg_sched,
										struct graphic_assembly_list *GA_list)
{
	int i, count;
	struct graphic_assembly *GA;

	count = 0;
	for ( i = 0; i < pg_sched->num_GAs; i++ ) {
		GA = ithGAInPageSchedule ( pg_sched, i, GA_list );

		if ( typeOfGA ( GA ) == FIXED_DIM ) {
			count++;
		}
	}

	return ( count );
}

static double targetAreaOfFixedDimensionsGAs ( struct page_schedule *pg_sched,
											   struct graphic_assembly_list *GA_list)
{
	int i, GA_index;
	double sum;
	struct page_schedule_entry *pse;
	struct graphic_assembly *GA;

	if ( numberOfFixedDimensionsGAs ( pg_sched, GA_list ) == 0 ) {
		return ( 0.0 );
	}

	sum = 0.0;
	for ( i = 0; i < pg_sched->num_GAs; i++ ) {
		pse = &( pg_sched->pse[i] );
		GA_index = pse->GA_index;
		GA = &( GA_list->GA[GA_index] );

		if ( typeOfGA ( GA ) == FIXED_DIM ) {
			sum += averageTargetAreaOfFixedDimensionsGA ( pse, GA_list );
		}
	}

	return ( sum / ((double)(numberOfFixedDimensionsGAs(pg_sched,GA_list))) );
}

static void computeTargetAreas ( struct config_params *cp, struct page_schedule *pg_sched,
								 struct graphic_assembly_list *GA_list )
{
	int i, j, GA_index;
	double conversion_factor;
	struct page_schedule_entry *pse;
	struct graphic_assembly *GA;
	struct graphic_element_schedule *GE_sched;

	// for GA's of type FIXED_DIM, set target area values to relative area values
	for ( i = 0; i < pg_sched->num_GAs; i++ ) {
		pse = &( pg_sched->pse[i] );
		GA_index = pse->GA_index;
		GA = &( GA_list->GA[GA_index] );

		if ( typeOfGA ( GA ) == FIXED_DIM ) {
			for ( j = 0; j < pse->num_GEs; j++ ) {
				GE_sched = &( pse->GE_scheds[j] );
				if ( GE_sched->relative_area < EPSILON ) {
					exitOrException("\nerror computing target areas for GA of type FIXED_DIM");
				}
				GE_sched->target_area = GE_sched->relative_area;
			}
		}
	}

	if ( pg_sched->num_GAs == numberOfFixedDimensionsGAs ( pg_sched, GA_list ) ) {
		return;
	}

	// for each photo GE, estimate an "ideal" target area 
	// (an absolute area, in square inches, say) 
	// assuming the photos fill the entire available area 
	//
	// the first estimate takes into account the spacing and borders
	// separating adjacent photos ... I expect it to work fine in general, 
	// but it involves solving a quadratic 
	// which generally can have complex solutions, and real but negative solutions,
	// and I haven't thought "all the way to the bottom" regarding whether in this code, 
	// there will always be exactly one real, positive solution (i.e. that we can use); 
	// so I'm also putting in a "reliable estimate" that should always produce an answer

	conversion_factor = conversionFactorEstimate ( cp, pg_sched, GA_list );

	if ( conversion_factor < EPSILON ) {
		conversion_factor = reliableConversionFactorEstimate ( cp, pg_sched, GA_list );
	}

	for ( i = 0; i < pg_sched->num_GAs; i++ ) {
		pse = &( pg_sched->pse[i] );
		GA_index = pse->GA_index;
		GA = &( GA_list->GA[GA_index] );

		if ( typeOfGA ( GA ) != FIXED_DIM ) {
			for ( j = 0; j < pse->num_GEs; j++ ) {
				GE_sched = &( pse->GE_scheds[j] );
				if ( GE_sched->relative_area < EPSILON ) {
					exitOrException("\nerror computing target areas for GA that is not of type FIXED_DIM");
				}
				GE_sched->target_area = ( GE_sched->relative_area ) * conversion_factor;
			}
		}
	}
}

static double conversionFactorEstimate ( struct config_params *cp, 
										 struct page_schedule *pg_sched,
										 struct graphic_assembly_list *GA_list )
{
	int i, j, GA_index, num_GEs;
	double k, A, B, C, aspect, discriminant, estimate;
	struct page_schedule_entry *pse;
	struct graphic_element_schedule *GE_sched;
	struct graphic_assembly *GA;

	// compute the total buffer that surrounds a photo in the interior of the layout
	//
	// here we assume all photo borders are the same and the specified spacing 
	// between adjacent borders is exactly INTER_GA_SPACING for each GE
	// 
	// ideally this should reflect the spacing specified for each individual photo;
	// generally, photos could have unique border values, 
	// and photos in groups or photo sequences might have different spacing values 
	k = cp->BORDER + ( 0.5 * ( cp->INTER_GA_SPACING ) );
	if ( k < 0.0 - EPSILON ) {
		// this is unexpected ... scrap the estimate
		return -1.0;
	}

	// compute the parameters of a quadratic equation A*x^2 + B*x + C = 0
	// 
	// if there is a positive, real root then take it to be the square root
	// of our conversion factor
	A = B = C = 0.0;
	num_GEs = 0;
	for ( i = 0; i < pg_sched->num_GAs; i++ ) {
		pse = &( pg_sched->pse[i] );
		GA_index = pse->GA_index;
		GA = &( GA_list->GA[GA_index] );

		// we only include GE's of type PHOTO;
		// GA's of type FIXED_DIM are accounted for by detracting from the usable area
		if ( typeOfGA ( GA ) != FIXED_DIM ) {
			if ( typeOfGA ( GA ) == PHOTO_VER ) {
				// PHOTO_VER: need to pick a version to use; for simplicity take the first
				GE_sched = &( pse->GE_scheds[0] );
				A += GE_sched->relative_area;
				aspect = GEAspectFromGAList ( &( GE_sched->GE_ID ), GA_list );
				B += sqrt ( GE_sched->relative_area ) * 2.0 * k * ( sqrt ( aspect ) + ( 1.0 / sqrt ( aspect ) ) );
				num_GEs += numVisibleGEs ( GA );
			}
			else {
				// PHOTO, PHOTO_SEQ, PHOTO_GRP
				for ( j = 0; j < pse->num_GEs; j++ ) {
					GE_sched = &( pse->GE_scheds[j] );
					A += GE_sched->relative_area;
					aspect = GEAspectFromGAList ( &( GE_sched->GE_ID ), GA_list );
					B += sqrt ( GE_sched->relative_area ) * 2.0 * k * ( sqrt ( aspect ) + ( 1.0 / sqrt ( aspect ) ) );
				}
				num_GEs += numVisibleGEs ( GA );
			}
		}
	}
	C = ((double)(num_GEs)) * 4.0 * k * k;
	C -= ( usableHeight ( cp ) ) * ( cp->INTER_GA_SPACING );
	C -= ( usableWidth  ( cp ) ) * ( cp->INTER_GA_SPACING );
	C -= ( cp->INTER_GA_SPACING ) * ( cp->INTER_GA_SPACING) ;
	C -= ( usableHeight ( cp ) ) * ( usableWidth ( cp ) );
	C += targetAreaOfFixedDimensionsGAs ( pg_sched, GA_list );

	discriminant = ( B * B ) - ( 4.0 * A * C );

	if ( discriminant < EPSILON ) {
		// the quadratic has either a double root or complex roots ... scrap the estimate
		return -1.0;
	}

	// the discriminant is positive so there are two real roots; 
	// if there is exactly one positive solution, then use it
	//
	// note that since B and A are both positive, 
	// so we are computing the only root that could possibly be positive,
	estimate = ( 0.0 - B + sqrt ( discriminant ) ) / ( 2.0 * A );

	if ( estimate < EPSILON ) {
		// both solutions are negative ... scrap the estimate
		return -1.0;
	}

	return ( estimate * estimate );
}

static double reliableConversionFactorEstimate ( struct config_params *cp, 
												 struct page_schedule *pg_sched,
												 struct graphic_assembly_list *GA_list )
{
	double total_relative_area, total_usable_area;

	// this estimate does not take into account the gutters and 
	// borders around photos 
	//
	// first, compute sum of relative area proportions of photo GE's 
	// that would appear on a complete page
	total_relative_area = photoRelativeAreaFromPageSchedule ( pg_sched, GA_list );
	if ( total_relative_area < EPSILON ) {
		exitOrException("\nerror computing target areas: not enough relative area");
	}

	// now compute the space available
	total_usable_area = usableHeight ( cp ) * usableWidth ( cp );
	total_usable_area -= targetAreaOfFixedDimensionsGAs ( pg_sched, GA_list );
	if ( total_usable_area < EPSILON ) {
		exitOrException("\nerror computing target areas: not enough usable area");
	}

	return ( total_usable_area / total_relative_area );
}

static void checkScoringTolerances ( double too_big, double way_too_big, 
									 double too_small, 
									 double way_too_small )
{
	if ( ( too_big < 1.0 - EPSILON )			||	// big thresholds must be in [1, Inf)
		 ( way_too_big < 1.0 - EPSILON )		|| 
		 ( too_small > 1.0 + EPSILON )			||	// small thresholds must be in [0,1]
		 ( too_small < 0.0 - EPSILON )			||
		 ( way_too_small > 1.0 + EPSILON )		||
	     ( way_too_small < 0.0 - EPSILON )		||
		 ( way_too_big < too_big )				||
		 ( too_big < too_small )				||
		 ( too_small < way_too_small ) ) {
		exitOrException("\ninvalid target area tolerances");
	}
}

static double GEActualToTargetAreaRatio ( struct GE_identifier *GEID, struct pbook_page *page,
										  struct graphic_assembly_list *GA_list )
{
	double target, actual;
	struct physical_rectangle *p_rect;

	p_rect = physRectFromGEID ( GEID, &( page->page_L ) );
	actual = p_rect->height * p_rect->width;

	target = GETargetArea ( GEID, &( page->sched ), GA_list );

	return ( actual / target );
}

static double GEActualToTargetHeightRatio ( struct GE_identifier *GEID, struct pbook_page *page,
											struct graphic_assembly_list *GA_list )
{
	double target, actual;
	struct physical_rectangle *p_rect;

	p_rect = physRectFromGEID ( GEID, &( page->page_L ) );
	actual = p_rect->height;

	target = GETargetHeight ( GEID, &( page->sched ), GA_list );

	return ( actual / target );
}

static double GEActualToTargetWidthRatio ( struct GE_identifier *GEID, struct pbook_page *page,
										   struct graphic_assembly_list *GA_list )
{
	double target, actual;
	struct physical_rectangle *p_rect;

	p_rect = physRectFromGEID ( GEID, &( page->page_L ) );
	actual = p_rect->width;

	target = GETargetWidth ( GEID, &( page->sched ), GA_list );

	return ( actual / target );
}

static double fixedDimensionsVersionTargetAreaScore ( struct GE_identifier *GEID, 
													  struct pbook_page *page,
													  struct graphic_assembly_list *GA_list )
{
	double height_ratio, height_dist, width_ratio, width_dist, dist;

	// generate scores for the height and the width
	height_ratio = GEActualToTargetHeightRatio ( GEID, page, GA_list );
	height_dist = distanceMapping ( height_ratio, FIXED_DIM_TOO_BIG, FIXED_DIM_WAY_TOO_BIG, 
									FIXED_DIM_TOO_SMALL, FIXED_DIM_WAY_TOO_SMALL );

	width_ratio = GEActualToTargetWidthRatio ( GEID, page, GA_list );
	width_dist = distanceMapping ( width_ratio, FIXED_DIM_TOO_BIG, FIXED_DIM_WAY_TOO_BIG, 
								   FIXED_DIM_TOO_SMALL, FIXED_DIM_WAY_TOO_SMALL );

	// between the two distances take the smaller
	dist = height_dist;
	if ( width_dist < height_dist ) dist = width_dist;

	return ( dist );
}

static double photoTargetAreaScore ( struct GE_identifier *GEID, struct pbook_page *page,
									  struct graphic_assembly_list *GA_list )
{
	double ratio, dist;

	ratio = GEActualToTargetAreaRatio ( GEID, page, GA_list );
	dist = distanceMapping ( ratio, PHOTO_TOO_BIG, PHOTO_WAY_TOO_BIG, PHOTO_TOO_SMALL, PHOTO_WAY_TOO_SMALL );

	return ( dist );
}

static double distanceMapping ( double ratio, double too_big, double way_too_big, 
								double too_small, double way_too_small )
{
	double dist;

	// best possible score
	dist = 1.0;

	// continuous penalty for the ratio being too small or too big
	//
	// way_too_small <= too_small <= 1.0 <= too_big
	if ( ratio < too_small ) {
		dist = ratio / too_small;
		if ( ratio < way_too_small ) {
			dist *= dist;
		}
	}
	else if ( ratio > too_big ) {
		dist = too_big / ratio;
		if ( ratio > way_too_big ) {
			dist *= dist;
		}
	}

	// we could get some really small distances 
	// but that should be just as well
	if ( dist < EPSILON ) dist = 2.0 * EPSILON;

	// distance should be in (0, 1]
	if ( ( dist < EPSILON ) || ( dist > 1.0 + EPSILON ) ) {
		exitOrException("\nerror computing distance mapping");
	}

	return ( dist );
}

static double photoGATargetAreaScore ( struct graphic_assembly *GA, 
										struct pbook_page *page,
										struct graphic_assembly_list *GA_list )
{
	struct photo *ph;

	if ( typeOfGA ( GA ) != PHOTO ) {
		exitOrException("\nerror computing target area score");
	}

	ph = &( GA->ph );
	return ( photoTargetAreaScore ( &( ph->GE_ID ), page, GA_list ) );
}

static double photoGrpGATargetAreaScore ( struct graphic_assembly *GA, 
										   struct pbook_page *page,
										   struct graphic_assembly_list *GA_list )
{
	int i;
	double dist;
	struct photo_grp *ph_grp;
	struct photo_grp_photo *ph_grp_ph;

	if ( typeOfGA ( GA ) != PHOTO_GRP ) {
		exitOrException("\nerror computing distance from layout to target areas");
	}

	ph_grp = &( GA->ph_grp );

	dist = 0.0;
	for ( i = 0; i < ph_grp->num_photos; i++ ) {
		ph_grp_ph = &( ph_grp->photo_grp_photos[i] );
		dist += photoTargetAreaScore ( &( ph_grp_ph->GE_ID ), page, GA_list );
	}

	return ( dist );
}

static double photoVerGATargetAreaScore ( struct graphic_assembly *GA, 
										   struct pbook_page *page,
										   struct graphic_assembly_list *GA_list )
{
	struct viewport *VP;

	if ( typeOfGA ( GA ) != PHOTO_VER ) {
		exitOrException("\nerror computing distance from layout to target areas");
	}

	VP = VPFromGAIndex ( GA->GA_index, &( page->page_L ) );
	return ( photoTargetAreaScore ( &( VP->GE_ID ), page, GA_list ) );
}

static double fixedDimensionsGATargetAreaScore ( struct graphic_assembly *GA, 
												 struct pbook_page *page,
												 struct graphic_assembly_list *GA_list )
{
	struct viewport *VP;

	if ( typeOfGA ( GA ) != FIXED_DIM ) {
		exitOrException("\nerror computing distance from layout to target areas");
	}

	VP = VPFromGAIndex ( GA->GA_index, &( page->page_L ) );
	return ( fixedDimensionsVersionTargetAreaScore ( &( VP->GE_ID ), page, GA_list ) );
}

static double photoSeqGATargetAreaScore ( struct graphic_assembly *GA, 
										   struct pbook_page *page,
										   struct graphic_assembly_list *GA_list )
{
	int i;
	double dist;
	struct photo_seq *ph_seq;
	struct photo *ph;

	if ( typeOfGA ( GA ) != PHOTO_SEQ ) {
		exitOrException("\nerror computing distance from layout to target areas");
	}

	ph_seq = &( GA->ph_seq );
	dist = 0.0;
	for ( i = 0; i < ph_seq->num_photos; i++ ) {
		ph = &( ph_seq->photos[i] );
		dist += photoTargetAreaScore ( &( ph->GE_ID ), page, GA_list );
	}

	dist /= ( ( double ) ( ph_seq->num_photos ) );
	return ( dist );
}

static double targetAreaScore ( struct pbook_page *page, 
								struct graphic_assembly_list *GA_list )
{
	int i;
	double score2, GA_score, photo_score, fd_score, group_multiplier;
	struct graphic_assembly *GA;

	photo_score = fd_score = 1.0;
	for ( i = 0; i < page->num_GAs; i++ ) {
		GA = GAFromTreeValue ( page->page_T, page->num_GAs, i+1, GA_list );

		if ( typeOfGA ( GA ) == PHOTO ) {
			GA_score = photoGATargetAreaScore ( GA, page, GA_list );
		}
		else if ( typeOfGA ( GA ) == PHOTO_GRP ) {
			GA_score = photoGrpGATargetAreaScore ( GA, page, GA_list );
		}
		else if ( typeOfGA ( GA ) == PHOTO_VER ) {
			GA_score = photoVerGATargetAreaScore ( GA, page, GA_list );
		}
		else if ( typeOfGA ( GA ) == FIXED_DIM ) {
			GA_score = fixedDimensionsGATargetAreaScore ( GA, page, GA_list );
		}
		else if ( typeOfGA ( GA ) == PHOTO_SEQ ) {
			GA_score = photoSeqGATargetAreaScore ( GA, page, GA_list );
		}
		else {
			exitOrException("\nerror computing target area score");
		}

		if ( typeOfGA ( GA ) == FIXED_DIM ) {
			if ( fd_score > GA_score ) fd_score = GA_score;
		}
		else {
			if ( photo_score > GA_score ) photo_score = GA_score;
		}
	}

	group_multiplier = 1.0;
	group_multiplier *= distanceMapping(fd_score,    1.0, 1.0+EPSILON, 0.3, 0.1);
	group_multiplier *= distanceMapping(photo_score, 1.0, 1.0+EPSILON, 0.3, 0.1);

	score2 = ( fd_score + photo_score ) * group_multiplier;
	if ( score2 < EPSILON ) {
		score2 = 2.0 * EPSILON;
	}

	return score2;
}

static double comboOfConsistencyAndAspect ( struct pbook_page *page, 
											struct GE_treeNode *GE_tree, 
											struct graphic_assembly_list *GA_list )
{
	double consistency, aspect_match, score;

	consistency = GEConsistency ( page, GA_list );
	aspect_match = aspectMatch ( page, &( GE_tree[0] ) );

	score = ( 1.5 * sqrt ( aspect_match ) ) + consistency;
	if ( consistency < 1.0 / 5.0 )  score *= consistency * 5.0;
	if ( aspect_match < 4.0 / 5.0 ) score *= aspect_match * 5.0 / 4.0;

	return ( score );
}

static double bbCoverage ( struct GE_treeNode *leaf, struct GE_treeNode *root )
{
	if ( leaf->bb_e < 0.0 ) {
		exitOrException("\ninvalid value for relative area of leaf");
	}
	if ( root->bb_e < 0.0 ) {
		exitOrException("\ninvalid value for relative area of root");
	}
	if ( leaf->bb_e > root->bb_e + EPSILON ) {
		exitOrException("\ndid not expect tree leaf to have greater area than root");
	}

	return ( ( leaf->bb_e ) / ( root->bb_e ) );
}


static struct viewport *VPFromGEID ( struct GE_identifier *GE_ID, struct layout *L )
{
	int count, i;
	struct viewport *VP;

	count = 0;
	for ( i = 0; i < L->num_VPs; i++ ) {
		if ( GEIDsAreEqual ( GE_ID, &( L->VPs[i].GE_ID ) ) ) {
			VP = &( L->VPs[i] );
			count++;
		}
	}

	if ( count != 1 ) {
		exitOrException("\nerror finding GE in layout listing");
	}

	return VP;
}


static double aspectMatch ( struct pbook_page *page, struct GE_treeNode *root )
{
	double pbb_a, page_a;

	if ( root->value != root->parent ) {
		exitOrException("\nerror finding root of VAP tree");
	}
	if ( root->bb_a < EPSILON ) {
		exitOrException("\ninvalid aspect ratio for principal bounding box");
	}

	pbb_a = root->bb_a;
	page_a = page->usable_height / page->usable_width;

	if ( pbb_a < page_a ) {
		return ( pbb_a / page_a );
	}
	else {
		return ( page_a / pbb_a) ;
	}
}


static void FAAccumBBs ( struct config_params *cp, struct GE_treeNode *T, 
						  int num_GEs, int value )
{
	struct GE_treeNode *node,*Rchild,*Lchild;
	double L_ht,R_ht,L_wd,R_wd,bb_ht,bb_wd;

	if ( value > 0 ) return;

	// compute bounding box for the present node 
	// from the bb_a and bb_e values of the R and L chilren,
	// including any spacing between the children

	node = & ( T[GEGetTreeIndex(T,treeLen(num_GEs),value)] );
	FAAccumBBs ( cp, T, num_GEs, node->Rchild );
	FAAccumBBs ( cp, T, num_GEs, node->Lchild );

	Rchild = & ( T[GEGetTreeIndex(T,treeLen(num_GEs),node->Rchild)] );
	Lchild = & ( T[GEGetTreeIndex(T,treeLen(num_GEs),node->Lchild)] );
	checkContentInfo ( Rchild->bb_a, Rchild->bb_e, Lchild->bb_a, Lchild->bb_e );

	R_ht = bbHeight ( Rchild ); 
	R_wd = bbWidth ( Rchild );
	L_ht = bbHeight ( Lchild ); 
	L_wd = bbWidth ( Lchild );

	if ( node->cut_dir == HORIZ ) {
		bb_ht = R_ht + node->cut_spacing + L_ht;
		if ( R_wd > L_wd )	{ bb_wd = R_wd; }
		else				{ bb_wd = L_wd; }
	}
	else {
		bb_wd = R_wd + node->cut_spacing + L_wd;
		if ( R_ht > L_ht )	{ bb_ht = R_ht; }
		else				{ bb_ht = L_ht; }
	}

	node->bb_e = bb_ht * bb_wd;
	node->bb_a = bb_ht / bb_wd;
}


static void extractPolishExpression ( struct subT_treeNode *T, int num_leaves,
									  int *P_e )
{
	int count;

	// the Polish expression is a non-negative sequence of length 2N-1 
	// where N is the # of GA's on the page
	//
	// a value of 0 means a HORIZ cut; a value of 1 means a VERT cut; 
	// and any other is the index of the GA assigned to the cell, plus two

	count = 0;
	addToPolishExpression ( T, num_leaves, T[0].value, P_e, &count );

	if ( count != treeLen ( num_leaves ) ) {
		exitOrException("\nerror generating polish expression from binary tree");
	}
}


static void addToPolishExpression ( struct subT_treeNode *T, int num_leaves,
								    int value, int *P_e, int *count )
{
	struct subT_treeNode *node;

	node = &(T[subTGetTreeIndex(T,treeLen(num_leaves),value)]);

	if ( value > 0 ) {
		// for a leaf node, assign the associated GA_index plus two
		P_e[*count] = node->subT_ID.GA_index + 2;
	}
	else {
		addToPolishExpression ( T, num_leaves, node->Lchild, P_e, count );
		addToPolishExpression ( T, num_leaves, node->Rchild, P_e, count );

		// for an interior node, assign the cut direction
		P_e[*count] = node->cut_dir;
	}

	(*count)++;
}


static void skewTree ( struct subT_treeNode *T, int num_leaves, int value )
{
	struct subT_treeNode *node,*Rchild,*Lchild;

	if ( value > 0 ) return;

	// skew the subtrees whose roots are the R and L chilren of "node,"
	// then skew the subtree whose root is "node"

	node = & ( T[subTGetTreeIndex(T,treeLen(num_leaves),value)] );
	skewTree ( T, num_leaves, node->Rchild );
	skewTree ( T, num_leaves, node->Lchild );

	Rchild = & ( T[subTGetTreeIndex(T,treeLen(num_leaves),node->Rchild)] );
	Lchild = & ( T[subTGetTreeIndex(T,treeLen(num_leaves),node->Lchild)] );

	// if the Rchild is a leaf node, there is nothing to do
	if ( Rchild->value > 0 )  return;

	// if cuts of node and Rchild do not match, there is nothing to do
	if ( node->cut_dir != Rchild->cut_dir ) return;

	// if Lchild is a leaf, only need to swap children 
	if ( Lchild->value > 0 ) {
		swapChildren ( node, Lchild->value, Rchild->value );
		return;
	}

	// if cuts of node and Lchild do not match, only need to swap children 
	if ( node->cut_dir != Lchild->cut_dir ) {
		swapChildren ( node, Lchild->value, Rchild->value );
		return;
	}

	// node and both children are cuts of same direction
	linearizeTriad ( T, num_leaves, node, Lchild, Rchild );
}


static void linearizeTriad ( struct subT_treeNode *T, int num_leaves, 
							 struct subT_treeNode *node, 
							 struct subT_treeNode *Lchild, 
							 struct subT_treeNode *Rchild )
{
	int node_is_root, node_parent_value, node_index, Rchild_index;
	struct subT_treeNode *node_parent, *Lchild_of_Rchild, *Rchild_of_Rchild, temp;

	// a "triad" is a node with its two children where the children are both 
	// interior nodes, and where all three have the same cut direction

	// verify that node and both children are cuts of same direction 
	if ( ( node->value > 0 ) || ( Rchild->value > 0 ) || ( Lchild->value > 0 ) ) {
		exitOrException("\nlinearizeTriad: expect points to be interior nodes");
	}
	if ( ( node->cut_dir != Rchild->cut_dir ) || ( node->cut_dir != Lchild->cut_dir ) ) {
		exitOrException("\nlinearizeTriad: expect cuts to be same direction");
	}

	// determine whether "node" is root of the entire tree;
	// if not, record the value of the parent of "node"
	if ( node->value == node->parent ) {
		node_is_root = 1;
	}
	else {
		node_is_root = 0;
		node_parent_value = node->parent;
	}

	// get the children of Rchild
	Lchild_of_Rchild = &(T[subTGetTreeIndex (T,treeLen(num_leaves),Rchild->Lchild)]);
	Rchild_of_Rchild = &(T[subTGetTreeIndex (T,treeLen(num_leaves),Rchild->Rchild)]);

	// make it so that Lchild_of_Rchild is the right child of "node"
	node->Rchild = Lchild_of_Rchild->value;
	Lchild_of_Rchild->parent = node->value;

	// make it so that node is the left child of Rchild
	Rchild->Lchild = node->value;
	node->parent = Rchild->value;

	// make it so that the subtree is properly topped off with Rchild as its root
	if ( node_is_root ) {
		Rchild->parent = Rchild->value;

		// swap Rchild and "node" in the array so the root can have index zero
		node_index = subTGetTreeIndex(T,treeLen(num_leaves),node->value);
		if ( node_index != 0 ) {
			exitOrException("\nlinearizeTriad: expected root to take zeroth index in tree");
		}
		Rchild_index = subTGetTreeIndex(T,treeLen(num_leaves),Rchild->value);

		temp = T[node_index];
		T[node_index] = T[Rchild_index];
		T[Rchild_index] = temp;
	}
	else {
		Rchild->parent = node_parent_value;

		node_parent = &(T[subTGetTreeIndex(T,treeLen(num_leaves),node_parent_value)]);
		if ( node_parent->Lchild == node->value ) {
			node_parent->Lchild = Rchild->value;
		}
		else if ( node_parent->Rchild == node->value ) {
			node_parent->Rchild = Rchild->value;
		}
		else {
			exitOrException("\nerror linearizing triad while skewing tree");
		}
	}

	// some error checking
	if ( ( node->Lchild != Lchild->value ) ||
		 ( Lchild->parent != node->value ) ||
		 ( node->Rchild != Lchild_of_Rchild->value ) ||
		 ( Lchild_of_Rchild->parent != node->value ) ||
		 ( node->parent != Rchild->value ) || 
		 ( Rchild->Lchild != node->value ) || 
		 ( Rchild->Rchild != Rchild_of_Rchild->value ) ||
		 ( Rchild_of_Rchild->parent != Rchild->value ) ) {
		exitOrException("\nlinearizeTriad: error modifying tree");
	}

	// now look at relationship between "node" and Lchild_of_Rchild

	// if Lchild_of_Rchild is a leaf we can stop 
	if ( Lchild_of_Rchild->value > 0 ) return;

	// if they have different cut directions we can stop 
	if ( node->cut_dir != Lchild_of_Rchild->cut_dir ) return;

	// "node", Lchild and Lchild_of_Rchild form a triad; 
	// fix that before we return control to skewTree
	linearizeTriad ( T, num_leaves, node, Lchild, Lchild_of_Rchild );
}


static void swapChildren ( struct subT_treeNode *parent, int L_value, int R_value )
{
	if ( parent->value > 0 ) {
		exitOrException("\ncould not swap children of a leaf node");
	}

	parent->Lchild = R_value;
	parent->Rchild = L_value;
}

static double bbWidth ( struct GE_treeNode *node )
{
	if ( ( node->bb_a < EPSILON ) || ( node->bb_e < 0.0 ) ) {
		exitOrException("\ncannot compute object width");
	}

	return ( sqrt ( node->bb_e / node->bb_a ) );
}


static double bbHeight ( struct GE_treeNode *node )
{
	if ( ( node->bb_a < EPSILON ) || ( node->bb_e < 0.0 ) ) {
		exitOrException("\ncannot compute object height");
	}

	return ( sqrt ( node->bb_e * node->bb_a ) );
}


static void checkContentInfo ( double R_a, double R_e, double L_a, double L_e )
{
	//
	// the e values can get very small ... before, I was checking to 
	// see whether x <= 0.00001 but with a large number of images on one page, 
	// the program would exit, and if I commented out this check, the program 
	// seemed to run OK ... so numerical instability may be a problem 
	// (i.e. if we ever encounter a "zero" that numerically is represented 
	// as a very small negative number) ...
	//

	if ( ( R_a < EPSILON ) || ( R_e < 0.0 ) ||
	     ( L_a < EPSILON ) || ( L_e < 0.0 ) ) {
		exitOrException("\nerror with content info");
	}
}

static void FAInitTermNodeBBs ( struct config_params *cp,
								 struct GE_treeNode *GE_tree, struct layout *L,
								 struct graphic_assembly_list *GA_list )
{
	int i, index;
	struct GE_treeNode *node;
	struct GE_identifier *GE_ID;
	struct physical_rectangle *p_rect;

	// provide values for bb_e and bb_a of each terminal node in the GE_tree
	// from the predetermined object dimensions in the layout

	if ( L->num_VPs <= 0 ) {
		exitOrException("\nneed at least one viewport to init terminal node BBs");
	}

	for ( i = 0; i < L->num_VPs; i++ ) {
		index = GEGetTreeIndex ( GE_tree, treeLen ( L->num_VPs ), i+1 );
		node = &( GE_tree[index] );

		GE_ID = &( node->GE_ID );
		p_rect = physRectFromGEID ( GE_ID, L );
		verifyPhysRectDimensions ( p_rect );

		node->bb_e = ( p_rect->height + ( 2.0 * node->border ) ) * ( p_rect->width + ( 2.0 * node->border ) );
		node->bb_a = ( p_rect->height + ( 2.0 * node->border ) ) / ( p_rect->width + ( 2.0 * node->border ) );
	}
}

static void subTToGE ( struct config_params *cp, struct GE_treeNode *new_GE_tree, 
						 struct pbook_page *page, int num_GEs,
						 struct graphic_assembly_list *GA_list )
{
	struct subT_treeNode *subT_tree;
	struct subT_identifier **subT_ID_mapping, *subT_ID;
	struct graphic_assembly *GA;
	struct GE_treeNode *GE_tree;
	int i, index, leaves_added; 

	if ( num_GEs < 1 ) {
		exitOrException("\ncan not create GE tree with zero GE's");
	}

	// look at the input tree, and record a mapping 
	// from the subT terminal node values to the associated subT_ID's 
	subT_tree = page->page_T;
	subT_ID_mapping = new struct subT_identifier * [ page->num_GAs + 1 ];
	subT_ID_mapping[0] = NULL;		// this will not be used
	for ( i = 1; i <= page->num_GAs; i++ ) {
		// here, i is the terminal node value, and we're copying 
		// the address of the subT_ID associated with the terminal node
		index = subTGetTreeIndex ( subT_tree, treeLen ( page->num_GAs ), i ); 
		subT_ID_mapping[i] = &( subT_tree[index].subT_ID ); 
	}

	// copy the structure (i.e. the graphic connections) of the subT tree 
	// into the structure of the GE tree (no need to copy the subT_ID's)
	//
	// notice that the set of interior nodes in the subT tree is exactly
	// the set of nodes that will separate GAs in the GE tree ... 
	// so when you copy a node that is an interior node in the subT tree, 
	// set the spacing parameter in the corresponding GE tree node to equal 
	// the inter GA spacing value
	for ( i = 0; i < treeLen ( page->num_GAs ); i++ ) {
		new_GE_tree[i].value   = subT_tree[i].value;
		new_GE_tree[i].parent  = subT_tree[i].parent;
		new_GE_tree[i].Lchild  = subT_tree[i].Lchild;
		new_GE_tree[i].Rchild  = subT_tree[i].Rchild;
		new_GE_tree[i].cut_dir = subT_tree[i].cut_dir;

		if ( subT_tree[i].value <= 0 ) {
			new_GE_tree[i].cut_spacing = cp->INTER_GA_SPACING;
			new_GE_tree[i].GA_index = -1;
		}
		else {
			new_GE_tree[i].cut_spacing = 0.0;
		}

		new_GE_tree[i].border = 0.0;
	}

	leaves_added = 0;
	for ( i = 1; i <= page->num_GAs; i++ ) {
		// replace leaf node having value i, with the actual GE subtree
		subT_ID = subT_ID_mapping[i];
		GA = &( GA_list->GA[subT_ID->GA_index] );
		GE_tree = GA->subTs[subT_ID->subT_index];

		GEReplaceLeafWithSubtree ( new_GE_tree, page->num_GAs + leaves_added, 
									i, GE_tree, numVisibleGEs ( GA ) );

		// the increment in the overall number of leaves 
		// is one less than the number of GEs in the subtree just added
		// since we *replaced* a leaf
		leaves_added += numVisibleGEs ( GA ) - 1;
	}

	if ( num_GEs != page->num_GAs + leaves_added ) {
		exitOrException("\nerror converting subT tree to graphic element tree");
	}

	GETestTree ( cp, new_GE_tree, num_GEs, GA_list->num_GAs );

	delete [] subT_ID_mapping;
}

static void GEReplaceLeafWithSubtree ( struct GE_treeNode *existing_tree,
										int existing_num_leaves, int value_displaced, 
										struct GE_treeNode *incoming_tree,
										int incoming_num_leaves )
{
	int i, existing_tree_len, incoming_tree_len;
	int *leaf_mapping, leaf_index, parent_index;
	struct GE_treeNode *temp_tree, *leaf, *parent;

	if ( ( existing_num_leaves <= 0 ) || ( incoming_num_leaves <= 0 ) ) {
		exitOrException("\ninvalid number of leaves");
	}
	if ( existing_tree[0].value != existing_tree[0].parent ) {
		exitOrException("\nexpected zeroth treeNode of existing_tree to be a root");
	}
	if ( incoming_tree[0].value != incoming_tree[0].parent ) {
		exitOrException("\nexpected zeroth treeNode of incoming_tree to be a root");
	}

	existing_tree_len = treeLen ( existing_num_leaves );
	incoming_tree_len = treeLen ( incoming_num_leaves );

	// make a temporary copy of the incoming tree 
	temp_tree = new struct GE_treeNode [ incoming_tree_len ];
	GECopyTree ( incoming_tree, temp_tree, incoming_num_leaves );

	// alter temp tree values so they do not interfere with the existing tree; 
	// notice we may need to fix the root node later
	leaf_mapping = new int [ incoming_num_leaves + 1 ];
	genLeafMapping ( leaf_mapping, value_displaced, incoming_num_leaves, existing_num_leaves );
	for ( i = 0; i < incoming_tree_len; i++ ) {
		adjustTreeValue ( &( temp_tree[i].value  ), existing_num_leaves, leaf_mapping );
		adjustTreeValue ( &( temp_tree[i].parent ), existing_num_leaves, leaf_mapping );
		if ( temp_tree[i].value <= 0 ) {
			adjustTreeValue ( &( temp_tree[i].Lchild ), existing_num_leaves, leaf_mapping );
			adjustTreeValue ( &( temp_tree[i].Rchild ), existing_num_leaves, leaf_mapping );
		}
		// if this is an interior node, the cut_direction and spacing remain unchanged;
		// if it is a terminal node, the GE_ID remains unchanged
	}
	delete [] leaf_mapping;

	// find the leaf we are going to discard (actually we will write over it)
	leaf_index = GEGetTreeIndex ( existing_tree, existing_tree_len, value_displaced );
	leaf = &( existing_tree[leaf_index] );

	if ( leaf->parent != leaf->value ) {
		// the leaf we are going to discard is not a root node
		//
		// the root of the incoming tree will have a parent
		// and that parent will have a new child value

		parent_index = GEGetTreeIndex ( existing_tree, existing_tree_len, leaf->parent );
		parent = &( existing_tree[parent_index] );

		// set the new child value for the parent
		if ( parent->Lchild == leaf->value ) {
			parent->Lchild = temp_tree[0].value;
		}
		else if ( parent->Rchild == leaf->value ) {
			parent->Rchild = temp_tree[0].value;
		}
		else {
			exitOrException("\nerror replacing leaf with subtree");
		}

		// set the new parent value for the root of the incoming tree
		temp_tree[0].parent = parent->value;
	}

	// write over the leaf whose value is being displaced 
	// with the root of the incoming tree, and then 
	// concatenate the existing tree with any additional incoming treeNodes 
	*leaf = temp_tree[0];
	for ( i = 1; i < incoming_tree_len; i++ ) {
		existing_tree[ existing_tree_len + i - 1 ] = temp_tree[i];
	}

	delete [] temp_tree;
}


static void genLeafMapping ( int *leaf_mapping, int value_displaced, 
							 int incoming_num_leaves, int existing_num_leaves )
{
	int i;

	// we will not use (*mapping)[0] ... 
	// we want to index (*mapping) with the values of the leaf nodes only
	//
	// assign the value being displaced first, since it is required 
	// to appear in the tree after the replacement is complete
	leaf_mapping[1] = value_displaced;
	for ( i = 2; i <= incoming_num_leaves; i++ ) {
		leaf_mapping[i] = existing_num_leaves + i - 1;
	}
}

static void adjustTreeValue ( int *value, int existing_num_leaves, int *leaf_mapping )
{
	if ( *value > 0 ) {
		*value = leaf_mapping[*value];
	}
	else {
		*value = *value - ( existing_num_leaves - 1 );
	}
}

static double GEConsistency ( struct pbook_page *page, struct graphic_assembly_list *GA_list )
{
	int i, j;
	double area, area_min, area_max, score;
	struct graphic_assembly *GA;

	area_min = 1.0;
	area_max = 0.0;
	for ( i = 0; i < page->num_GAs; i++ ) {
		GA = GAFromTreeValue ( page->page_T, page->num_GAs, i+1, GA_list );

		if ( typeOfGA ( GA ) != PHOTO_GRP ) {
			area = GAAreaFromLayout ( GA, &(page->page_L) );

			if ( i == 0 ) { area_min = area_max = area; }
			else { updateMinAndMax ( area, &area_min, &area_max ); }
		}
		else {
			for ( j = 0; j < GA->ph_grp.num_photos; j++ ) {
				area = photoGrpPhotoAreaFromLayout ( GA, j, &(page->page_L) );

				if ( ( i == 0 ) && ( j == 0 ) ) { area_min = area_max = area; }
				else { updateMinAndMax ( area, &area_min, &area_max ); }
			}
		}
	}

	if ( area_min > area_max ) {
		exitOrException("\nerror computing consistency score");
	}

	score = area_min / area_max;

	if ( ( score < 0.0 ) || ( score > 1.0 + EPSILON ) ) {
		exitOrException("\ninvalid consistency score");
	}
	return score;
}

static void updateMinAndMax ( double area, double *area_min, double *area_max )
{
	if ( area < (*area_min) ) { *area_min = area; }
	if ( area > (*area_max) ) { *area_max = area; }
}

static double GAAreaFromLayout ( struct graphic_assembly *GA, struct layout *L )
{
	int i;
	double area;

	if ( typeOfGA ( GA ) == PHOTO ) {
		area = photoAreaFromLayout ( GA, L );
	}
	else if ( typeOfGA ( GA ) == PHOTO_GRP ) {
		area = 0.0;
		for ( i = 0; i < GA->ph_grp.num_photos; i++ ) {
			area += photoGrpPhotoAreaFromLayout ( GA, i, L );
		}
	}
	else if ( typeOfGA ( GA ) == PHOTO_VER ) {
		area = photoVerAreaFromLayout ( GA, L );
	}
	else if ( typeOfGA ( GA ) == FIXED_DIM ) {
		area = fixedDimensionsVersionAreaFromLayout ( GA, L );
	}
	else if ( typeOfGA ( GA ) == PHOTO_SEQ ) {
		area = photoSeqAreaFromLayout ( GA, L );
	}
	else {
		exitOrException("\nerror determining GA area from layout");
	}

	return area;
}

static double GAHeightFromLayout ( struct graphic_assembly *GA, struct layout *L )
{
	struct viewport *VP;
	struct physical_rectangle *p_rect;

	if ( ( typeOfGA ( GA ) == PHOTO_GRP ) || ( typeOfGA ( GA ) == PHOTO_SEQ ) ) {
		exitOrException("\nerror getting photo height from layout\n");
	}

	VP = VPFromGAIndex ( GA->GA_index, L );
	p_rect = physRectFromGEID ( &( VP->GE_ID ), L );
	verifyPhysRectDimensions(p_rect);

	return ( p_rect->height );
}

static double GAWidthFromLayout ( struct graphic_assembly *GA, struct layout *L )
{
	struct viewport *VP;
	struct physical_rectangle *p_rect;

	if ( ( typeOfGA ( GA ) == PHOTO_GRP ) || ( typeOfGA ( GA ) == PHOTO_SEQ ) ) {
		exitOrException("\nerror getting photo width from layout\n");
	}

	VP = VPFromGAIndex ( GA->GA_index, L );
	p_rect = physRectFromGEID ( &( VP->GE_ID ), L );
	verifyPhysRectDimensions(p_rect);

	return ( p_rect->width );
}

static double photoAspectFromLayout ( struct graphic_assembly *GA, struct layout *L )
{
	struct photo *ph;
	struct physical_rectangle *p_rect;

	if ( typeOfGA ( GA ) != PHOTO ) {
		exitOrException("\nerror computing photo aspect from layout");
	}

	ph = &( GA->ph );
	p_rect = physRectFromGEID ( &( ph->GE_ID ), L );
	verifyPhysRectDimensions ( p_rect );
	return ( p_rect->height / p_rect->width );
}

static double photoAreaFromLayout ( struct graphic_assembly *GA, struct layout *L )
{
	struct physical_rectangle *p_rect;

	if ( typeOfGA ( GA ) != PHOTO ) {
		exitOrException("\nerror computing photo area from layout");
	}

	p_rect = physRectFromGAIndex ( GA->GA_index, L );
	verifyPhysRectDimensions ( p_rect );
	return ( p_rect->height * p_rect->width );
}

static double photoGrpPhotoAspectFromLayout ( struct graphic_assembly *GA, 
											  int photo_index, struct layout *L )
{
	struct photo_grp *ph_grp;
	struct photo_grp_photo *ph_grp_ph;
	struct physical_rectangle *p_rect;

	if ( typeOfGA ( GA ) != PHOTO_GRP ) {
		exitOrException("\nerror determining photo group photo aspect from layout");
	}

	ph_grp = &( GA->ph_grp );
	if ( ( photo_index < 0 ) || ( photo_index >= ph_grp->num_photos ) ) {
		exitOrException("\nerror determining photo group photo area from layout");
	}

	ph_grp_ph = &( ph_grp->photo_grp_photos[photo_index] );
	p_rect = physRectFromGEID ( &( ph_grp_ph->GE_ID ), L );
	verifyPhysRectDimensions ( p_rect );
	return ( p_rect->height / p_rect->width );
}

static double photoGrpPhotoAreaFromLayout ( struct graphic_assembly *GA, 
										    int photo_index, struct layout *L )
{
	struct photo_grp *ph_grp;
	struct photo_grp_photo *ph_grp_ph;
	struct physical_rectangle *p_rect;

	if ( typeOfGA ( GA ) != PHOTO_GRP ) {
		exitOrException("\nerror determining photo group photo area from layout");
	}

	ph_grp = &( GA->ph_grp );
	if ( ( photo_index < 0 ) || ( photo_index >= ph_grp->num_photos ) ) {
		exitOrException("\nerror determining photo group photo area from layout");
	}

	ph_grp_ph = &( ph_grp->photo_grp_photos[photo_index] );
	p_rect = physRectFromGEID ( &( ph_grp_ph->GE_ID ), L );
	verifyPhysRectDimensions ( p_rect );
	return ( p_rect->height * p_rect->width );
}

static double photoVerAreaFromLayout ( struct graphic_assembly *GA, struct layout *L )
{
	struct physical_rectangle *p_rect;
	
	if ( typeOfGA ( GA ) != PHOTO_VER ) {
		exitOrException("\nerror computing photo version area from layout");
	}

	p_rect = physRectFromGAIndex ( GA->GA_index, L );
	verifyPhysRectDimensions ( p_rect );
	return ( p_rect->height * p_rect->width );
}

static double fixedDimensionsVersionAreaFromLayout ( struct graphic_assembly *GA, 
													 struct layout *L )
{
	struct physical_rectangle *p_rect;
	
	if ( typeOfGA ( GA ) != FIXED_DIM ) {
		exitOrException("\nerror computing fixed-dimensions version area from layout");
	}

	p_rect = physRectFromGAIndex ( GA->GA_index, L );
	verifyPhysRectDimensions ( p_rect );
	return ( p_rect->height * p_rect->width );
}

static double photoSeqAreaFromLayout ( struct graphic_assembly *GA, struct layout *L )
{
	double area;
	int k;
	struct photo_seq *ph_seq;
	struct photo *ph;
	struct physical_rectangle *p_rect;
	
	if ( typeOfGA ( GA ) != PHOTO_SEQ ) {
		exitOrException("\nerror computing photo seq area from layout");
	}

	ph_seq = &( GA->ph_seq );
	area = 0.0;
	for ( k = 0; k < ph_seq->num_photos; k++ ) {
		ph = &( ph_seq->photos[k] );
		p_rect = physRectFromGEID ( &( ph->GE_ID ), L );
		verifyPhysRectDimensions ( p_rect );
		area += ( p_rect->height * p_rect->width );
	}

	return area;
}

static struct physical_rectangle *physRectFromGEID ( struct GE_identifier *GE_ID, 
													 struct layout *L )
{
	struct viewport *VP;
	struct physical_rectangle *p_rect;

	VP = VPFromGEID ( GE_ID, L );
	p_rect = &( VP->p_rect );

	return p_rect;
}

static void verifyPhysRectDimensions ( struct physical_rectangle *p_rect )
{
	if ( ( p_rect->height < EPSILON ) || ( p_rect->width < EPSILON ) ) {
		exitOrException("\ndid not expect physical rectangle to have miniscule area");
	}
}

static struct viewport *VPFromGAIndex ( int GA_index, struct layout *L )
{
	int found, k;
	struct viewport *VP, *soughtafter_VP;

	found = 0;
	for ( k = 0; k < L->num_VPs; k++ ) {
		VP = &( L->VPs[k] );
		if ( VP->GE_ID.GA_index == GA_index ) {
			soughtafter_VP = VP;
			found++;
		}
	}

	if ( found != 1 ) {
		exitOrException("\nerror finding viewport in layout structure from GA_index");
	}

	return ( soughtafter_VP );
}

static struct physical_rectangle *physRectFromGAIndex ( int GA_index, struct layout *L )
{
	struct viewport *VP;

	VP = VPFromGAIndex ( GA_index, L );

	return ( &( VP->p_rect ) );
}

static int updateScore ( struct pbook_page *page, struct subT_treeNode *best_T,
						 struct layout *best_L,
						 struct graphic_assembly_list *GA_list )
{
	double score;

	// determine score 
	score = page->page_L.score;
	if ( score < 0.0 ) { exitOrException ( "\ninvalid score" ); }

	// EPSILON ensures the new score beats the old score by just a little
	if ( score > BEST_LAYOUT_SCORE + EPSILON ) {
		if ( best_T != NULL ) {
			subTCopyTree ( page->page_T, best_T, page->num_GAs );
		}
		if ( best_L != NULL ) {
			copyLayout ( &( page->page_L ), best_L );
		}
		BEST_LAYOUT_SCORE = score; 

		return 1;
	}

	return 0;
}


static void clearScore ( )
{
	BEST_LAYOUT_SCORE = -1.0;
}

static void printGAList ( struct graphic_assembly_list *GA_list )
{
	int i;
	struct graphic_assembly *GA;

	printf("-- BEGIN GA_list --\n");
	for ( i = 0; i < GA_list->num_GAs; i++ ) {
		GA = &( GA_list->GA[i] );
		printGraphicAssemblyInfo ( GA, GA_list );
	}
	printf("-- END GA_list --\n");
}

static void printGraphicAssemblyInfo ( struct graphic_assembly *GA,
									   struct graphic_assembly_list *GA_list )
{
	struct photo *ph;
	struct photo_grp *ph_grp;
	struct photo_grp_photo *ph_grp_ph;
	struct photo_ver *ph_ver;
	struct fixed_dimensions *fd;
	struct fixed_dimensions_version *fd_ver;
	struct photo_seq *ph_seq;
	int i;

	if ( GA->type == PHOTO ) {
		ph = &(GA->ph);

		if ( GA->GA_index != ph->GE_ID.GA_index ) {
			exitOrException("\nunexpected disagreement in graphic assembly indices");
		}

		printf("%d\tPHOTO, %d subT%(s%)",ph->GE_ID.GA_index, GA->num_subTs);
		printf("\n");
		printf("%d.%d\t\t",ph->GE_ID.GA_index,ph->GE_ID.GE_index);
		printf("%s, ",filenameFromPath ( ph->filename ));
		printf("ht=%d, wd=%d",ph->height,ph->width);
		printf("\n");
	}
	else if ( GA->type == PHOTO_GRP ) {
		ph_grp = &(GA->ph_grp);

		printf("%d\tPHOTO GROUP, %d subT%(s%), %d photos",GA->GA_index,
			GA->num_subTs,ph_grp->num_photos);
		printf("\n");

		for ( i = 0; i < ph_grp->num_photos; i++ ) {
			ph_grp_ph = & ( ph_grp->photo_grp_photos[i] );

			if ( GA->GA_index != ph_grp_ph->GE_ID.GA_index ) {
				exitOrException("\nunexpected disagreement in graphic assembly indices");
			}

			printf("%d.%d\t\t",ph_grp_ph->GE_ID.GA_index,ph_grp_ph->GE_ID.GE_index);
			ph = photoFromPhotoGrpGEID ( &( ph_grp_ph->GE_ID ), GA_list );
			printf("ph # %d %s, ",i,filenameFromPath ( ph->filename ));
			printf("ht=%d, wd=%d, ",ph->height,ph->width);
			printf("\n");
		}
	}
	else if ( GA->type == PHOTO_VER ) {
		ph_ver = &(GA->ph_ver);

		printf("%d\tPHOTO VERSIONS, %d versions",GA->GA_index,ph_ver->num_versions);
		printf("\n");

		for ( i = 0; i < ph_ver->num_versions; i++ ) {
			ph = & ( ph_ver->photos[i] );

			if ( GA->GA_index != ph->GE_ID.GA_index ) {
				exitOrException("\nunexpected disagreement in graphic assembly indices");
			}

			printf("%d.%d\t\t",ph->GE_ID.GA_index,ph->GE_ID.GE_index);
			printf("ph # %d %s, ",i,filenameFromPath ( ph->filename ));
			printf("ht=%d, wd=%d, ",ph->height,ph->width);
			printf("\n");
		}
	}
	else if ( GA->type == FIXED_DIM ) {
		fd = &(GA->fd);

		printf("%d\tFIXED DIMENSIONS GA, %d versions\n",GA->GA_index,fd->num_fd_versions);

		for ( i = 0; i < fd->num_fd_versions; i++ ) {
			fd_ver = & ( fd->fd_versions[i] );

			if ( GA->GA_index != fd_ver->GE_ID.GA_index ) {
				exitOrException("\nunexpected disagreement in graphic assembly indices");
			}

			printf("%d.%d\t\t",fd_ver->GE_ID.GA_index,fd_ver->GE_ID.GE_index);
			printf("ht=%lf, wd=%lf\n",fd_ver->height,fd_ver->width);
		}
	}
	else if ( GA->type == PHOTO_SEQ ) {
		ph_seq = &(GA->ph_seq);

		printf("%d\tPHOTO SEQUENCE, %d subT%(s%), %d photos with ",
			   GA->GA_index,GA->num_subTs,ph_seq->num_photos);
		printf("\n");

		printf("**\trow-column configs: ");
		for ( i = 0; i < ph_seq->num_rc_cfgs; i++ ) {
			printf("%dx%d; ",ph_seq->rc_cfgs[i].num_rows,ph_seq->rc_cfgs[i].num_cols);
		}
		printf("\n");

		for ( i = 0; i < ph_seq->num_photos; i++ ) {
			ph = & ( ph_seq->photos[i] );

			if ( GA->GA_index != ph->GE_ID.GA_index ) {
				exitOrException("\nunexpected disagreement in graphic assembly indices");
			}

			printf("%d.%d\t\t",ph->GE_ID.GA_index,ph->GE_ID.GE_index);
			printf("ph # %d %s, ",i,filenameFromPath ( ph->filename ));
			printf("ht=%d, wd=%d, ",ph->height,ph->width);
			printf("\n");
		}
	}
	else {
		exitOrException("\nerror printing out graphic assembly info");
	}
}


static void printTruncatedString ( char *string )
{
	size_t STRING_TRUNC = 15;
	int i;

	if ( strlen ( string ) <= STRING_TRUNC - 3 ) {
		printf("%s",string);
		for ( i = 0; i < (int) ( STRING_TRUNC - strlen ( string ) ); i++ ) {
			printf(" ");
		}
	}
	else {
		char *temp_str = new char [ STRING_TRUNC + 4 ];
		strncpy ( temp_str, string, STRING_TRUNC );
		temp_str[STRING_TRUNC  ] = '.';
		temp_str[STRING_TRUNC+1] = '.';
		temp_str[STRING_TRUNC+2] = '.';
		temp_str[STRING_TRUNC+3] = '\0';
		printf("%s",temp_str);
		delete [] temp_str;
	}
}


static char *filenameFromPath ( char *path )
{
	char drive[_MAX_DRIVE];
	char dir[_MAX_DIR];
	static char fname[_MAX_FNAME];
	char ext[_MAX_EXT];

	_splitpath( path, drive, dir, fname, ext );

	return fname;
}

static void genPhotoSublayouts ( int GA_index, struct graphic_assembly_list *GA_list )
{
	struct graphic_assembly *GA;
	struct GE_treeNode *T1;
	struct photo *ph;

	GA = &( GA_list->GA[GA_index] );
	verifyPhotoGA ( GA );

	// make a first subT with the photo
	T1 = GA->subTs[0];
	ph = &( GA->ph );
	GEInitTree ( T1, &( ph->GE_ID ) );
}

static void getScratchPageAspects ( struct double_list *scratch_page_aspects )
{
	int num_photo_arrangements;

	// for now use a hard-coded set of aspect ratios
	num_photo_arrangements = numPhotoGrpArrangements ( );
	if ( num_photo_arrangements != 5 ) {
		exitOrException("\nmaking group sublayouts: unexpected # photo arrangements");
	}
	initDoubleList ( scratch_page_aspects, num_photo_arrangements );

//	scratch_page_aspects->doubles[0] = 1.0;

//	scratch_page_aspects->doubles[0] = 0.7  / 1.0;
//	scratch_page_aspects->doubles[1] = 1.0;
//	scratch_page_aspects->doubles[2] = 1.0 / 0.70;

	scratch_page_aspects->doubles[0] = 0.35 / 1.0;
	scratch_page_aspects->doubles[1] = 0.7  / 1.0;
	scratch_page_aspects->doubles[2] = 1.0;
	scratch_page_aspects->doubles[3] = 1.0 / 0.70;
	scratch_page_aspects->doubles[4] = 1.0 / 0.35;

	scratch_page_aspects->num_doubles = num_photo_arrangements;
}

static void recordPageTreeAsPhotoGrpSublayout ( struct config_params *cp,
												struct pbook_page *page,
												struct graphic_assembly *group_GA,
												int sublayout_index,
												struct graphic_assembly_list *GA_list )
{
	int i;
	struct GE_treeNode *GE_tree, *node, *T;
	struct GE_identifier *photo_GEID;

	if ( page->num_GAs <= 0 ) {
		exitOrException("\nerror recording photo group sublayout - page must have at least one GA");
	}
	if ( sublayout_index < 0 ) {
		exitOrException("\nerror recording photo group sublayout - invalid sublayout index");
	}

	// take the subT_tree from the page, get the GE_tree induced by it,
	// and replace the GE_ID's at the leaves with the values from the photo group
	GE_tree = new struct GE_treeNode [ treeLen ( page->num_GAs ) ];
	subTToGE ( cp, GE_tree, page, page->num_GAs, GA_list );
	for ( i = 0; i < treeLen ( page->num_GAs ); i++ ) {
		node = &( GE_tree[i] );
		if ( node->value > 0 ) {
			photo_GEID = photoGrpGEIDFromPhotoGEID ( group_GA, &( node->GE_ID ), GA_list );
			node->GE_ID = *photo_GEID; 
		}
	}

	// record the modified GE_tree as a sublayout for the photo group
	T = group_GA->subTs[sublayout_index];
	GECopyTree ( GE_tree, T, page->num_GAs );

	delete [] GE_tree;
}

static void genPhotoGrpSublayouts ( struct config_params *cp, int group_GA_index,
									struct graphic_assembly_spec *GA_spec,
									struct graphic_assembly_list *GA_list )
{
	int i, photo_GA_index;
	double scratch_page_aspect;
	struct photo_grp *ph_grp;
	struct photo_grp_photo *ph_grp_ph;
	struct GE_identifier *photo_GEID;
	struct double_list scratch_page_aspects;
	struct config_params scratch_cp;
	struct page_schedule scratch_pg_sched;
	struct page_list scratch_page_list;
	struct graphic_assembly *group_GA, *photo_GA;
	struct pbook_page *scratch_page;
	struct photo_grp_spec *ph_grp_spec;
	struct photo_spec *ph_spec;

	verifyPhotoGrpGA ( group_GA_index, GA_list );

	group_GA = &( GA_list->GA[group_GA_index] );
	ph_grp = & ( group_GA->ph_grp );
	if ( ph_grp->num_photos == 1 ) {
		ph_grp_ph = &( ph_grp->photo_grp_photos[0] );
		photo_GEID = photoGEIDFromPhotoGrpGEID ( &( ph_grp_ph->GE_ID ), GA_list );
		GEInitTree ( group_GA->subTs[0], photo_GEID );
	}
	else {
		// make a new page schedule with the photos in this photo group
		initPageSchedule ( &scratch_pg_sched, ph_grp->num_photos );
		ph_grp_spec = &( GA_spec->ph_grp_spec );
		for ( i = 0; i < ph_grp->num_photos; i++ ) {
			ph_grp_ph = &( ph_grp->photo_grp_photos[i] );
			photo_GA_index = ph_grp_ph->photo_GA_index;
			photo_GA = &( GA_list->GA[photo_GA_index] );
			addGAToPageSchedule ( photo_GA, &scratch_pg_sched );

			ph_spec = &( ph_grp_spec->ph_specs[i] );
			recordAreasFromThinAir ( &scratch_pg_sched, photo_GA_index, GA_list, ph_spec->area );
		}
		checkPageSchedule ( &scratch_pg_sched );

		// get a list of scratch_page aspect ratios 
		getScratchPageAspects ( &scratch_page_aspects );

		// set up the config params for these trials
		// the only thing that changes inside loop is the dimensions of the scratch page
		scratch_cp = *cp;
		scratch_cp.leftMargin = 0.0;
		scratch_cp.rightMargin = 0.0;
		scratch_cp.topMargin = 0.0;
		scratch_cp.bottomMargin = 0.0;

		// ready to generate the sublayouts
		for ( i = 0; i < scratch_page_aspects.num_doubles; i++ ) {
			// generate one sublayout on its own "scratch page"
			// having appropriate dimensions
			scratch_page_aspect = scratch_page_aspects.doubles[i];
			scratch_cp.pageHeight = sqrt ( cp->pageHeight * cp->pageWidth * scratch_page_aspect );
			scratch_cp.pageWidth  = sqrt ( cp->pageHeight * cp->pageWidth / scratch_page_aspect );
			runPageSchedulePlacementTrials ( &scratch_cp, &scratch_page_list, &scratch_pg_sched, GA_list );

			// use the subT_tree in the top page in the page list
			scratch_page = &( scratch_page_list.pages[0] );

			// the call to runPageSchedulePlacementTrials may have caused the GA_list to be realloc'ed;
			// just in case, set up the pointer to the GA according to the group_GA_index
			group_GA = &( GA_list->GA[group_GA_index] );

			recordPageTreeAsPhotoGrpSublayout ( cp, scratch_page, group_GA, i, GA_list );

			deletePageList ( &scratch_cp, &scratch_page_list );
		}
	}
}

static void genPhotoVerSublayouts ( int GA_index, struct graphic_assembly_list *GA_list )
{
	struct graphic_assembly *GA;
	struct photo_ver *ph_ver;
	struct photo *ph;
	struct GE_treeNode *T1;
	int k;

	GA = &( GA_list->GA[GA_index] );
	verifyPhotoVerGA ( GA );

	ph_ver = & ( GA->ph_ver );

	for ( k = 0; k < ph_ver->num_versions; k++ ) {
		T1 = GA->subTs[k];
		ph = &( ph_ver->photos[k] );
		GEInitTree ( T1, &( ph->GE_ID ) );
	}
}

static void genFixedDimensionsSublayouts ( int GA_index, struct graphic_assembly_list *GA_list )
{
	int i;
	struct graphic_assembly *GA;
	struct fixed_dimensions *fd;
	struct fixed_dimensions_version *fd_ver;
	struct GE_treeNode *T1;

	GA = &( GA_list->GA[GA_index] );
	verifyFixedDimensionsGA ( GA );

	fd = & ( GA->fd );
	for ( i = 0; i < fd->num_fd_versions; i++ ) {
		T1 = GA->subTs[i];
		fd_ver = &( fd->fd_versions[i] );
		GEInitTree ( T1, &( fd_ver->GE_ID ) );
	}
}

static void genPhotoSeqSublayouts ( int GA_index, struct graphic_assembly_list *GA_list )
{
	struct graphic_assembly *GA;
	struct GE_treeNode *T;
	struct photo_seq *ph_seq;
	struct photo *ph, *prev_ph;
	int k, i, j, num_rows, num_cols, count, index;

	GA = &( GA_list->GA[GA_index] );
	verifyPhotoSeqGA ( GA );

	// make a reduced set of subTs with the photos only

	ph_seq = & ( GA->ph_seq );
	for ( k = 0; k < ph_seq->num_rc_cfgs; k++ ) {
		T = GA->subTs[k];
		num_rows = ph_seq->rc_cfgs[k].num_rows;
		num_cols = ph_seq->rc_cfgs[k].num_cols;
		count = 0;

		for ( i = 0; i < num_rows; i++ ) {
			for ( j = 0; j < num_cols; j++ ) {

				if ( count >= ph_seq->num_photos ) {
					exitOrException("\ntried to add invalid # of photos to subT");
				}
				ph = &( ph_seq->photos[count] );

				if ( j != 0 ) {
					// add next photo to right of most recently added photo
					if ( count <= 0 ) {
						exitOrException("\nerror generating subtrees for photo sequence");
					}
					prev_ph = &( ph_seq->photos[count-1] );
					index = treeIndexFromGEID ( T, count, &(prev_ph->GE_ID) );
					GE_addLeafToTree ( T, &(ph->GE_ID), T, count, index, VERT );
				}
				else if ( i != 0 ) {
					// add photo by displacing the root node 
					GE_addLeafToTree ( T, &(ph->GE_ID), T, count, 0, HORIZ );
				}
				else {
					// i == 0 and j == 0, so initialize the tree
					GEInitTree ( T, &( ph->GE_ID ) );
				}

				count++;
			}
		}

		if ( count != ph_seq->num_photos ) {
			exitOrException("\nerror generating subtrees for photo sequence");
		}
	}
}

static void genSublayouts ( struct config_params *cp, int GA_index,
							struct graphic_assembly_spec *GA_spec,
							struct graphic_assembly_list *GA_list )
{
	struct graphic_assembly *GA;

	determineNum_subTs ( GA_index, GA_list );
	alloc_subTs ( GA_index, GA_list );

	GA = &( GA_list->GA[GA_index] );
	if ( typeOfGA ( GA ) == PHOTO ) {
		genPhotoSublayouts ( GA_index, GA_list );
	}
	else if ( typeOfGA ( GA ) == PHOTO_GRP ) {
		genPhotoGrpSublayouts ( cp, GA_index, GA_spec, GA_list );
	}
	else if ( typeOfGA ( GA ) == PHOTO_VER ) {
		genPhotoVerSublayouts ( GA_index, GA_list );
	}
	else if ( typeOfGA ( GA ) == FIXED_DIM ) {
		genFixedDimensionsSublayouts ( GA_index, GA_list );
	}
	else if ( typeOfGA ( GA ) == PHOTO_SEQ ) {
		genPhotoSeqSublayouts ( GA_index, GA_list );
	}

	setSublayoutSpacingValues ( cp, GA_index, GA_list );
	setGAIndices ( GA_index, GA_list );
}

static void generateGA ( struct config_params *cp, int GA_index,
						 struct graphic_assembly_spec *GA_spec,
						 struct graphic_assembly_list *GA_list )
{
	if ( GA_list->num_GAs < 1 ) {
		exitOrException("\nGA_list struct not prepared for recording of a new GA structure");
	}
	if ( ( GA_index < 0 ) || ( GA_index >= GA_list->num_GAs ) ) {
		exitOrException("\nunable to generate GA: invalid GA_index");
	}

	if ( GA_spec->type == PHOTO ) {
		generatePhotoGA ( cp, GA_index, GA_list, GA_spec );
	}
	else if ( GA_spec->type == PHOTO_GRP ) {
		generatePhotoGrpGA ( cp, GA_index, GA_list, GA_spec );
	}
	else if ( GA_spec->type == PHOTO_VER ) {
		generatePhotoVerGA ( cp, GA_index, GA_list, GA_spec );
	}
	else if ( GA_spec->type == FIXED_DIM ) {
		generateFixedDimGA ( cp, GA_index, GA_list, GA_spec );
	}
	else if ( GA_spec->type == PHOTO_SEQ ) {
		generatePhotoSeqGA ( cp, GA_index, GA_list, GA_spec );
	}
	else {
		exitOrException("\nunable to generate GA:  invalid GA specification type");
	}

	// assign a GE identifier to each photo in the GA;
	// record in the GA_spec the index of the GA this specification generated;
	// and record in each photo_spec of the GA_spec, 
	// the identifier of the GE assigned to the photo this photo_spec generated
	assignGEIDs ( GA_index, GA_list );
	GA_spec->GA_index = GA_index;
	recordGEIDsInGASpec ( GA_index, GA_spec, GA_list );

	// make the sublayouts
	genSublayouts ( cp, GA_index, GA_spec, GA_list );
}

static void fillInPhotoHeightField ( struct photo *ph, struct photo_spec *ph_spec )
{
	if ( ph_spec->pixel_height > 0 ) {
		ph->height = ph_spec->pixel_height;
	}
	else {
		exitOrException("\nexpected valid photo height in photo spec");
	}
}

static void fillInPhotoWidthField ( struct photo *ph, struct photo_spec *ph_spec )
{
	if ( ph_spec->pixel_width > 0 ) {
		ph->width = ph_spec->pixel_width;
	}
	else {
		exitOrException("\nexpected valid photo width in photo spec");
	}
}

static void fillInCropRegionField ( struct photo *ph, struct photo_spec *ph_spec )
{
	if ( ph_spec->has_crop_region == 1 ) {
		ph->has_crop_region = 1;
		ph->crop_region = ph_spec->crop_region;
	}
	else {
		// default is that there is no crop region
		ph->has_crop_region = 0;
	}
}

static void fillInROIField ( struct photo *ph, struct photo_spec *ph_spec )
{
	if ( ph_spec->has_ROI == 1 ) {
		ph->has_ROI = 1;
		ph->ROI = ph_spec->ROI;
	}
	else {
		// default is that there is no ROI
		ph->has_ROI = 0;
	}
}

static void generatePhotoGA ( struct config_params *cp, int GA_index,
							  struct graphic_assembly_list *GA_list,
							  struct graphic_assembly_spec *GA_spec )
{
	struct graphic_assembly *GA;
	struct photo *ph;
	struct photo_spec *ph_spec;

	GA = &( GA_list->GA[GA_index] );

	if ( GA_spec->type != PHOTO ) {
		exitOrException("\nunable to generate photo GA: invalid GA_spec type");
	}
	GA->type = GA_spec->type;

	ph = &( GA->ph );
	ph_spec = &( GA_spec->ph_spec );

	ph->filename = ph_spec->filename;
	fillInPhotoHeightField ( ph, ph_spec );
	fillInPhotoWidthField ( ph, ph_spec );
	fillInCropRegionField ( ph, ph_spec );
	fillInROIField ( ph, ph_spec );
}

static void generatePhotoGrpGA ( struct config_params *cp, int GA_index,
								 struct graphic_assembly_list *GA_list,
								 struct graphic_assembly_spec *GA_spec )
{
	int i;
	struct graphic_assembly *GA;
	struct photo_grp *ph_grp;
	struct photo_grp_spec *ph_grp_spec;
	struct photo_spec *ph_spec;
	struct photo_grp_photo *ph_grp_ph;
	struct GE_identifier *GE_ID;

	if ( GA_spec->type != PHOTO_GRP ) {
		exitOrException("\nunable to generate photo group GA: invalid GA_spec type");
	}

	GA = &( GA_list->GA[GA_index] );
	GA->type = GA_spec->type;

	ph_grp = &( GA->ph_grp );
	ph_grp_spec = &( GA_spec->ph_grp_spec );

	// number of photos
	ph_grp->num_photos = ph_grp_spec->num_photo_specs;

	// for each GA of type photo that is part of the group, record the GA_index 
	ph_grp->photo_grp_photos = new struct photo_grp_photo [ ph_grp->num_photos ];
	for ( i = 0; i < ph_grp->num_photos; i++ ) {
		ph_grp_ph = &( ph_grp->photo_grp_photos[i] );

		ph_spec = &( ph_grp_spec->ph_specs[i] );
		GE_ID = &( ph_spec->GE_ID );
		ph_grp_ph->photo_GA_index = GE_ID->GA_index;
	}
}

static void generatePhotoVerGA ( struct config_params *cp, int GA_index,
								 struct graphic_assembly_list *GA_list,
								 struct graphic_assembly_spec *GA_spec )
{
	int i;
	struct graphic_assembly *GA;
	struct photo_ver *ph_ver; 
	struct photo_ver_spec *ph_ver_spec;
	struct photo *ph;
	struct photo_spec *ph_spec;

	if ( GA_spec->type != PHOTO_VER ) {
		exitOrException("\nunable to generate photo versions GA: invalid GA_spec type");
	}

	GA = &( GA_list->GA[GA_index] );
	GA->type = GA_spec->type;

	ph_ver = &( GA->ph_ver );
	ph_ver_spec = &( GA_spec->ph_ver_spec );

	// number of photos 
	ph_ver->num_versions = ph_ver_spec->num_photo_specs;

	// photos
	ph_ver->photos = new struct photo [ ph_ver->num_versions ];
	for ( i = 0; i < ph_ver->num_versions; i++ ) {
		ph = &( ph_ver->photos[i] );
		ph_spec = &( ph_ver_spec->ph_specs[i] );

		ph->filename = ph_spec->filename;
		fillInPhotoHeightField ( ph, ph_spec );
		fillInPhotoWidthField ( ph, ph_spec );
		fillInCropRegionField ( ph, ph_spec );
		fillInROIField ( ph, ph_spec );
	}
}

static void generateFixedDimGA ( struct config_params *cp, int GA_index,
								 struct graphic_assembly_list *GA_list,
								 struct graphic_assembly_spec *GA_spec )
{
	int i;
	struct graphic_assembly *GA;
	struct fixed_dimensions *fd; 
	struct fixed_dimensions_spec *fd_spec; 
	struct fixed_dimensions_version *fd_ver; 
	struct fixed_dimensions_version_spec *fd_ver_spec; 

	if ( GA_spec->type != FIXED_DIM ) {
		exitOrException("\nunable to generate fixed dimensions GA: invalid GA_spec type");
	}

	GA = &( GA_list->GA[GA_index] );
	GA->type = GA_spec->type;

	fd = &( GA->fd );
	fd_spec = &( GA_spec->fd_spec );

	// number of versions
	fd->num_fd_versions = fd_spec->num_fd_version_specs;

	// versions
	fd->fd_versions = new struct fixed_dimensions_version [ fd->num_fd_versions ];
	for ( i = 0; i < fd->num_fd_versions; i++ ) {
		fd_ver = &( fd->fd_versions[i] );
		fd_ver_spec = &( fd_spec->fd_version_specs[i] );

		fd_ver->height = fd_ver_spec->height;
		fd_ver->width = fd_ver_spec->width;
	}
}

static void generatePhotoSeqGA ( struct config_params *cp, int GA_index,
								 struct graphic_assembly_list *GA_list,
								 struct graphic_assembly_spec *GA_spec )
{
	int i;
	struct graphic_assembly *GA;
	struct photo_seq *ph_seq; 
	struct photo_seq_spec *ph_seq_spec;
	struct photo *ph;
	struct photo_spec *ph_spec;

	if ( GA_spec->type != PHOTO_SEQ ) {
		exitOrException("\nunable to generate photo sequence GA: invalid GA_spec type");
	}

	GA = &( GA_list->GA[GA_index] );
	GA->type = GA_spec->type;

	ph_seq = &( GA->ph_seq );
	ph_seq_spec = &( GA_spec->ph_seq_spec );

	// number of photos
	ph_seq->num_photos = ph_seq_spec->num_photo_specs;

	// photos
	ph_seq->photos = new struct photo [ ph_seq->num_photos ];
	for ( i = 0; i < ph_seq->num_photos; i++ ) {
		ph = &( ph_seq->photos[i] );
		ph_spec = &( ph_seq_spec->ph_specs[i] );

		ph->filename = ph_spec->filename;
		fillInPhotoHeightField ( ph, ph_spec );
		fillInPhotoWidthField ( ph, ph_spec );
		ph->has_crop_region = 0;	// crop region not supported 
		ph->has_ROI = 0;			// ROI not supported 
	}
	// verify all the photos have about the same dimensions
	verifyPhotoDimensions ( ph_seq );
}

static int allocateOneNewGA ( struct graphic_assembly_list *GA_list )
{
	int i;
	struct graphic_assembly *prev_GA_array, *GA;

	if ( GA_list->num_GAs < 0 ) {
		exitOrException("\nerror allocating new GA -- invalid number of GA's");
	}

	if ( GA_list->num_GAs > 0 ) {
		prev_GA_array = GA_list->GA;
	}

	GA_list->GA = new struct graphic_assembly [ GA_list->num_GAs + 1 ];

	if ( GA_list->num_GAs > 0 ) {
		for ( i = 0; i < GA_list->num_GAs; i++ ) {
			// no need to re-allocate the things 
			// that are pointed to from within the GA structure 
			// (the subT's, the photo filename)
			GA_list->GA[i] = prev_GA_array[i];
		}

		delete [] prev_GA_array;
	}

	// assign values to the fields of the new GA
	//
	// many of these values are invalid; we will come back
	// and assign real values later ... for now we write down 
	// a minimal set of values
	// that will help us know when something is going wrong
	GA = &( GA_list->GA[GA_list->num_GAs] );
	GA->type = NO_TYPE;
	GA->GA_index = GA_list->num_GAs;
	GA->num_subTs = 0;
	GA->subTs = NULL;

	// increment num_GAs 
	(GA_list->num_GAs)++;

	return ( GA->GA_index );
}

static void verifyPhotoDimensions ( struct photo_seq *ph_seq )
{
	double DIM_TOL, ref_ht, ref_wd, ht, wd;
	int i;

	// set a tolerance on the image dimensions
	DIM_TOL = 0.025;

	ref_ht = (double)(ph_seq->photos[0].height);
	ref_wd = (double)(ph_seq->photos[0].width);

	for ( i = 1; i < ph_seq->num_photos; i++ ) {

		ht = (double)(ph_seq->photos[i].height);
		wd = (double)(ph_seq->photos[i].width);

		if ( ( (fabs(ht-ref_ht)/ref_ht) > DIM_TOL ) ||
			 ( (fabs(wd-ref_wd)/ref_wd) > DIM_TOL ) ) {
			exitOrException("\nphotos dimensions in photo sequence do not agree");
		}

	}
}

static void setSpacingValuesFromPageDimensions ( struct config_params *cp )
{
	double usable_width, usable_height, min;

	usable_width = usableWidth ( cp );
	usable_height = usableHeight ( cp );

	if ( ( usable_width < EPSILON ) || ( usable_height < EPSILON ) ) {
		exitOrException("\ninsufficient usable width given page dimensions and margins");
	}

	min = usable_height;
	if ( usable_width < usable_height ) min = usable_width;

	cp->INTER_GA_SPACING = min / 96.0;
	cp->PHOTO_GRP_SPACING = cp->INTER_GA_SPACING / PHOTO_GRP_SPACING_RATIO;
	cp->PHOTO_SEQ_SPACING = cp->INTER_GA_SPACING / PHOTO_SEQ_SPACING_RATIO;
}


static void confirmSpacingValues ( struct config_params *cp ) 
{
	if ( cp->INTER_GA_SPACING > 0.0 - EPSILON ) {
		// the INTER_GA_SPACING was specified, so if necessary, 
		// we can use it to compute values for PHOTO_GRP_SPACING 
		// and PHOTO_SEQ_SPACING

		if ( cp->PHOTO_GRP_SPACING < 0.0 - EPSILON ) {
			cp->PHOTO_GRP_SPACING = cp->INTER_GA_SPACING / PHOTO_GRP_SPACING_RATIO;
		}

		if ( cp->PHOTO_SEQ_SPACING < 0.0 - EPSILON ) {
			cp->PHOTO_SEQ_SPACING = cp->INTER_GA_SPACING / PHOTO_SEQ_SPACING_RATIO;
		}
	}
	else if ( ( cp->PHOTO_GRP_SPACING > 0.0 - EPSILON ) || 
			  ( cp->PHOTO_SEQ_SPACING > 0.0 - EPSILON ) ) {
		// no INTER_GA_SPACING was specified, but we can compute a value using
		// one of the spacing parameters that was specified; 
		//
		// use PHOTO_GRP_SPACING if available, otherwise use PHOTO_SEQ_SPACING

		if ( ( cp->PHOTO_GRP_SPACING > 0.0 - EPSILON ) && 
			 ( cp->PHOTO_SEQ_SPACING > 0.0 - EPSILON ) ) {
			// both values were specified explcitly; 
			// we only need to compute INTER_GA_SPACING 
			cp->INTER_GA_SPACING = cp->PHOTO_GRP_SPACING * PHOTO_GRP_SPACING_RATIO;
		}
		else if ( cp->PHOTO_GRP_SPACING > 0.0 - EPSILON ) {
			// compute INTER_GA_SPACING from PHOTO_GRP_SPACING 
			cp->INTER_GA_SPACING = cp->PHOTO_GRP_SPACING * PHOTO_GRP_SPACING_RATIO;

			// now compute PHOTO_SEQ_SPACING from INTER_GA_SPACING
			cp->PHOTO_SEQ_SPACING = cp->INTER_GA_SPACING / PHOTO_SEQ_SPACING_RATIO;
		}
		else if ( cp->PHOTO_SEQ_SPACING > 0.0 - EPSILON ) {
			// compute INTER_GA_SPACING from PHOTO_SEQ_SPACING 
			cp->INTER_GA_SPACING = cp->PHOTO_SEQ_SPACING * PHOTO_SEQ_SPACING_RATIO;

			// now compute PHOTO_GRP_SPACING from INTER_GA_SPACING
			cp->PHOTO_GRP_SPACING = cp->INTER_GA_SPACING / PHOTO_GRP_SPACING_RATIO;
		}
		else {
			exitOrException("\nerror determining spacing parameters");
		}
	}
	else {
		printf("computing all spacing values based on page dimensions\n");
		setSpacingValuesFromPageDimensions ( cp );
	}
}

static void checkConfigValues ( struct config_params *cp )
{
	checkNumLayouts ( cp );
	checkOptimizeLayoutValues ( cp );
	checkFixedDimDiscardThreshold ( cp );
	checkLayoutRotationValues ( cp );
	checkSpacingValues ( cp );
	checkMargins ( cp );
	checkUseROI ( cp );
	checkCarefulMode ( cp );

	checkScoringTolerances ( PHOTO_TOO_BIG, PHOTO_WAY_TOO_BIG, 
							 PHOTO_TOO_SMALL, PHOTO_WAY_TOO_SMALL );
	checkScoringTolerances ( FIXED_DIM_TOO_BIG, FIXED_DIM_WAY_TOO_BIG, 
							 FIXED_DIM_TOO_SMALL, FIXED_DIM_WAY_TOO_SMALL );
}

static void checkCarefulMode ( struct config_params *cp )
{
	if ( ( cp->CAREFUL_MODE != 0 ) && ( cp->CAREFUL_MODE != 1 ) ) {
		exitOrException("\nvalue of CAREFUL_MODE must be either 1 or 0");
	}
}

static void checkUseROI ( struct config_params *cp )
{
	if ( ( cp->USE_ROI != 0 ) && ( cp->USE_ROI != 1 ) ) {
		exitOrException("\nvalue of USE_ROI must be either 1 or 0");
	}
}

static void checkSpacingValues ( struct config_params *cp )
{
	if ( ( cp->INTER_GA_SPACING < 0.0 - EPSILON ) || 
		 ( cp->PHOTO_GRP_SPACING < 0.0 - EPSILON ) ||
		 ( cp->PHOTO_SEQ_SPACING < 0.0 - EPSILON ) ||
		 ( cp->BORDER < 0.0 - EPSILON ) ) {
		exitOrException("\nat least one invalid spacing value");
	}
}

static void checkMargins ( struct config_params *cp )
{
	if ( ( cp->pageHeight <= cp->topMargin + cp->bottomMargin ) ||
		 ( cp->pageWidth <= cp->leftMargin + cp->rightMargin  ) ) {
		exitOrException("\npage dimensions are incompatible with margins");
	}
}

static void checkLayoutRotationValues ( struct config_params *cp )
{
	if ( ( cp->LAYOUT_ROTATION != 1 ) && ( cp->LAYOUT_ROTATION != 0 ) ) {
		exitOrException("\ninvalid layout rotation values");
	}
	if ( cp->ROTATION_CAPACITY <= 0 ) {
		exitOrException("\ninvalid layout rotation values");
	}
	if ( cp->ROTATION_PPP_THRESHOLD < 0 ) {
		exitOrException("\ninvalid layout rotation values");
	}
}

static void checkOptimizeLayoutValues ( struct config_params *cp )
{
	if ( cp->OPTIMIZE_LAYOUT_PPP_THRESHOLD < 0 ) {
		exitOrException("\nvalue of OPTIMIZE_LAYOUT_PPP_THRESHOLD must be zero or positive");
	}
}

static void checkFixedDimDiscardThreshold ( struct config_params *cp )
{
	if ( cp->FIXED_DIM_DISCARD_THRESHOLD < 0.0 - EPSILON ) {
		exitOrException("\nvalue of FIXED_DIM_DISCARD_THRESHOLD must be zero or positive");
	}
}

static void checkNumLayouts ( struct config_params *cp )
{
	if ( cp->NUM_OUTPUT_LAYOUTS < 1 ) {
		exitOrException("\nnum output layouts must be positive");
	}

	if ( cp->NUM_WORKING_LAYOUTS < cp->NUM_OUTPUT_LAYOUTS ) {
		exitOrException("\nnum output layouts may not be greater than num working layouts");
	}
}




static int exeMode ( int argc, char **argv )
{
	int i, exe_mode, exe_mode_count;

	exe_mode = UNDEFINED_EXE_MODE;
	exe_mode_count = 0;
	for ( i = 1; i < argc; i++ ) {
		if ( strcmp ( argv[i], "-newpage" ) == 0 ) {
			exe_mode = NEWPAGE;
			exe_mode_count++;
		}
		else if ( strcmp ( argv[i], "-differentpage" ) == 0 ) {
			exe_mode = DIFFERENTPAGE;
			exe_mode_count++;
		}
		else if ( strcmp ( argv[i], "-swap" ) == 0 ) {
			exe_mode = SWAP;
			exe_mode_count++;
		}
		else if ( strcmp ( argv[i], "-crop" ) == 0 ) {
			exe_mode = CROP;
			exe_mode_count++;
		}
		else if ( strcmp ( argv[i], "-setborder" ) == 0 ) {
			exe_mode = SETBORDER;
			exe_mode_count++;
		}
		else if ( strcmp ( argv[i], "-setspacing" ) == 0 ) {
			exe_mode = SETSPACING;
			exe_mode_count++;
		}
		else if ( strcmp ( argv[i], "-setmargin" ) == 0 ) {
			exe_mode = SETMARGIN;
			exe_mode_count++;
		}
		else if ( strcmp ( argv[i], "-setBSM" ) == 0 ) {
			exe_mode = SETBSM;
			exe_mode_count++;
		}
		else if ( strcmp ( argv[i], "-setdimensions" ) == 0 ) {
			exe_mode = SETDIMENSIONS;
			exe_mode_count++;
		}
		else if ( strcmp ( argv[i], "-replace" ) == 0 ) {
			exe_mode = REPLACE;
			exe_mode_count++;
		}
	}

	if ( exe_mode_count != 1 ) {
		printf("invalid number of exe mode indicators on cmd line\n");
		exitOrException("\nusage: pbook { -newpage OR -differentpage OR -swap OR -crop OR -setborder OR -setspacing OR -setmargin OR -setBSM OR -setdimensions OR -replace } ...");
	}

	if ( ( exe_mode != NEWPAGE ) && 
		 ( exe_mode != DIFFERENTPAGE ) && 
		 ( exe_mode != SWAP ) && 
		 ( exe_mode != CROP ) && 
		 ( exe_mode != SETBORDER ) && 
		 ( exe_mode != SETSPACING ) && 
		 ( exe_mode != SETMARGIN ) && 
		 ( exe_mode != SETBSM ) && 
		 ( exe_mode != SETDIMENSIONS ) &&
		 ( exe_mode != REPLACE ) ) {
		printf("invalid exe mode determined from cmd line\n");
		exitOrException("\nusage: pbook { -newpage OR -differentpage OR -swap OR -crop OR -setborder OR -setspacing OR -setmargin OR -setBSM OR -setdimensions OR -replace } ...");
	}

	return ( exe_mode );
}
