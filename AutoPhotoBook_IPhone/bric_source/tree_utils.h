void reflectSubTTreeTopToBottom ( struct pbook_page *page, struct subT_treeNode *node );
void reflectSubTTreeLeftToRight ( struct pbook_page *page, struct subT_treeNode *node );
int pseudoRandomNumber ( int max );
double pseudoRandomZeroOne ( );
void seedPseudoRandomNumber ( int seed );
int GEIDsAreEqual ( struct GE_identifier *GE1, struct GE_identifier *GE2 );
int GEIDsAreNotEqual ( struct GE_identifier *GE1, struct GE_identifier *GE2 );
int subTIDsAreEqual ( struct subT_identifier *subT1, struct subT_identifier *subT2 );
int subTIDsAreNotEqual ( struct subT_identifier *subT1, struct subT_identifier *subT2 );
int typeOfGA ( struct graphic_assembly *GA );
int typeOfGASpec ( struct graphic_assembly_spec *GA_spec );
int oneGAHasMoreThanOnePresentation ( struct page_schedule *pg_sched,
									  struct graphic_assembly_list *GA_list );
struct graphic_assembly *ithGAInPageSchedule ( struct page_schedule *pg_sched, int i, 
											   struct graphic_assembly_list *GA_list );
struct photo *photoFromGEID ( struct GE_identifier *GE_ID,
							  struct graphic_assembly_list *GA_list );
struct fixed_dimensions_version *fixedDimensionsVersionFromGEID ( struct GE_identifier *GE_ID,
																  struct graphic_assembly_list *GA_list );
struct graphic_assembly *GAFromGEID ( struct GE_identifier *GE_ID,
										 struct graphic_assembly_list *GA_list );
struct graphic_assembly *GAFromTreeValue ( struct subT_treeNode *T, int num_leaves, 
											int value, 
											struct graphic_assembly_list *GA_list );
struct subT_identifier *subTIDFromTreeValue ( struct subT_treeNode *T,
											  int num_leaves, int value );
int subTGetTreeIndex ( struct subT_treeNode *T, int tree_length, int value );
struct GE_treeNode *GETreeLeftChild ( struct GE_treeNode *GE_tree, struct GE_treeNode *node,
									  int num_GEs );
struct GE_treeNode *GETreeRightChild ( struct GE_treeNode *GE_tree, struct GE_treeNode *node,
									   int num_GEs );
struct GE_treeNode *GETreeParent ( struct GE_treeNode *GE_tree, struct GE_treeNode *node,
								   int num_GEs );
struct GE_treeNode *GETreeNode ( struct GE_treeNode *GE_tree, int node_value,
								 int num_GEs );
int GEGetTreeIndex ( struct GE_treeNode *T, int tree_length, int value );
int treeValueFromSubTID ( struct subT_treeNode *T, int num_leaves, 
						  struct subT_identifier *subT_ID );
struct subT_treeNode *subTTreeNodeFromGAIndex ( struct pbook_page *page, int GA_index );
struct subT_treeNode *subTTreeNodeFromTreeValue ( struct pbook_page *page, int node_value );
int subTTreeValueFromGAIndex ( struct subT_treeNode *T, int num_leaves, int GA_index );
struct GE_treeNode *GETreeNodeFromGAIndex ( struct GE_treeNode *GE_tree, 
											int num_leaves, int GA_index, 
											struct graphic_assembly_list *GA_list );
int GETreeValueFromGEID ( struct GE_treeNode *T, int num_leaves, 
						  struct GE_identifier *GE_ID );
int treeIndexFromGEID ( struct GE_treeNode *T, int num_leaves, 
						 struct GE_identifier *GE_ID );
void GEInitTree ( struct GE_treeNode *T, struct GE_identifier *GE_ID );
void subTInitTree ( struct subT_treeNode *T, struct subT_identifier *subT_ID );
void GERemoveLeafFromTree ( struct GE_treeNode *T, int input_num_leaves,
						  struct GE_identifier *GE_ID );
void subTRemoveLeafFromTree ( struct subT_treeNode **T, int input_num_leaves,
							  int GA_index );
void GE_addLeafToTree ( struct GE_treeNode *old_T, struct GE_identifier *GE_ID, 
						struct GE_treeNode *new_T, 
						int old_num_leaves, int node_index, int cut_dir );
void subTAddLeafToTree ( struct subT_treeNode *old_T, 
						 struct subT_identifier *subT_ID, 
						 struct subT_treeNode *new_T, 
						 int old_num_leaves, int node_index, int cut_dir );
int treeLen ( int num_term_nodes );
void GECopyTree ( struct GE_treeNode *from_T, struct GE_treeNode *to_T, int num_leaves );
void subTCopyTree ( struct subT_treeNode *from_T, struct subT_treeNode *to_T, 
					int num_leaves );
void printSubTTree ( struct subT_treeNode *subT_tree, int num_leaves );
void printGETree ( struct GE_treeNode *GE_tree, int num_leaves );
void GETestTree ( struct config_params *cp, struct GE_treeNode *GE_tree, 
				   int num_leaves, int num_GAs );
struct graphic_element_schedule *GEScheduleFromGEID ( struct GE_identifier *GE_ID,
													  struct page_schedule *pg_sched,
													  struct graphic_assembly_list *GA_list );
double photoRelativeAreaFromGA ( struct graphic_assembly *GA, struct pbook_page *page,
								 struct graphic_assembly_list *GA_list );
double GERelativeArea ( struct GE_identifier *GE_ID, struct page_schedule *pg_sched,
						struct graphic_assembly_list *GA_list );
double GETargetArea ( struct GE_identifier *GEID, struct page_schedule *pg_sched,
					  struct graphic_assembly_list *GA_list );
double GERelativeHeight ( struct GE_identifier *GEID, struct page_schedule *pg_sched,
						  struct graphic_assembly_list *GA_list );
double GETargetHeight ( struct GE_identifier *GEID, struct page_schedule *pg_sched,
						struct graphic_assembly_list *GA_list );
double GERelativeWidth ( struct GE_identifier *GEID, struct page_schedule *pg_sched,
						 struct graphic_assembly_list *GA_list );
double GETargetWidth ( struct GE_identifier *GEID, struct page_schedule *pg_sched,
					   struct graphic_assembly_list *GA_list );
int GAsAreSimilarPhotos ( struct config_params *cp,
						  struct graphic_assembly *GA1, struct graphic_assembly *GA2,
						  struct page_schedule *pg_sched,
						  struct graphic_assembly_list *GA_list );
int GEsHaveFairlySimilarAspects ( struct GE_identifier *GEID1, struct GE_identifier *GEID2,
								  struct graphic_assembly_list *GA_list );
double GEAspectFromGAList ( struct GE_identifier *GE_ID, struct graphic_assembly_list *GA_list );
int numVisibleGEs ( struct graphic_assembly *GA );
void alloc_subTs ( int GA_index, struct graphic_assembly_list *GA_list );
void verifyPhotoGA ( struct graphic_assembly *GA );
void verifyPhotoGrpGA ( int GA_index, struct graphic_assembly_list *GA_list );
void copyIntegerList ( struct integer_list *from_list, struct integer_list *to_list );
void initIntegerList ( struct integer_list *list, int max_num_integers );
void initGEIDList ( struct GE_identifier_list *list, int max_GEIDs );
void deleteIntegerList ( struct integer_list *list );
void deleteGEIDList ( struct GE_identifier_list *list );
void initDoubleList ( struct double_list *list, int max_num_doubles );
void deleteDoubleList ( struct double_list *list );
struct GE_identifier *photoGrpGEIDFromPhotoGEID ( struct graphic_assembly *GA, 
												  struct GE_identifier *photo_GEID,
												  struct graphic_assembly_list *GA_list );
struct photo *photoFromPhotoGrpGEID ( struct GE_identifier *photo_grp_GEID,
									  struct graphic_assembly_list *GA_list );
struct GE_identifier *photoGEIDFromPhotoGrpGEID ( struct GE_identifier *photo_grp_GEID,
												  struct graphic_assembly_list *GA_list );
void verifyPhotoVerGA ( struct graphic_assembly *GA );
void verifyFixedDimensionsGA ( struct graphic_assembly *GA );
void verifyPhotoSeqGA ( struct graphic_assembly *GA );
int typeOfGE ( struct GE_identifier *GE_ID, struct graphic_assembly_list *GA_list );
void recordGEIDsInGASpec ( int GA_index, struct graphic_assembly_spec *GA_spec,
						   struct graphic_assembly_list *GA_list );
void assignGEIDs ( int GA_index, struct graphic_assembly_list *GA_list );
int numPhotoGrpArrangements ( );
void determineNum_subTs ( int GA_index, struct graphic_assembly_list *GA_list );
void setSublayoutSpacingValues ( struct config_params *cp, int GA_index,
								 struct graphic_assembly_list *GA_list );
void setGAIndices ( int GA_index, struct graphic_assembly_list *GA_list );
